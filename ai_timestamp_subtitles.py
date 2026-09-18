#!/usr/bin/env python3

"""
The script takes:
- a 16 kHz mono input audio file that is assumed to contain vocal track only
  with no other sounds or excessive noise
- an input text file assumed to contain non-timestamped text matching the vocal
  tracks (e.g. song lyrics for Karaoke)

then it outputs a timestamped subtitles file in ASS format.
"""

import whisperx
import pysubs2
import numpy as np
import os

# The input file must be mono and have 16 kHz sampling rate. We don't
# do format conversions here for brevity.
audio_file = "input_16kHz_mono.wav"
lyrics_file = "input_lyrics.txt"
output_ass_file = "output_subtitles.ass"
# We don't read the audio duration from its metadata either, for brevity.
# Set this to the correct value or write your own pre-processing code for that.
duration_in_seconds = 359.0

device = "cuda"

# 1. Load pre-existing correct lyrics, must match the vocal track exactly
with open(lyrics_file, "r", encoding="utf-8") as f:
    ground_truth_lyrics = [line.strip() for line in f.readlines() if line.strip() and not line.startswith("[")]

# 2. Combine the lines into a single, continuous stream to pass to the alignment model
full_text_stream = " ".join(ground_truth_lyrics)

# 3. Load Audio and the Phoneme Alignment Engine natively
audio = whisperx.load_audio(audio_file)
print("Loading ASR Alignment Model...")
model_a, metadata = whisperx.load_align_model(language_code="en", device=device)

# 4. Pass the entire text stream as a single continuous block from 0 to the end
input_segments = [{"text": full_text_stream, "start": 0.0, "end": duration_in_seconds}]

print("Analyzing isolated vocal waves and executing forced word alignment...")
aligned_result = whisperx.align(input_segments, model_a, metadata, audio, device,
                                 return_char_alignments=False)

# 5. Flatten every successfully recognized word into a single sequential timeline
all_recognized_words = []
if aligned_result.get("segments"):
    for segment in aligned_result["segments"]:
        for w in segment.get("words", []):
            if "start" in w and "end" in w:
                all_recognized_words.append(w)

# 6. Reconstruct original lines with dynamic statistical adjustments
subs = pysubs2.SSAFile()
word_pointer = 0

print("Rebuilding lyrics layout using generalized statistical heuristics...")
for line in ground_truth_lyrics:
    line_tokens = line.split()
    line_word_objects = []
    
    # Extract the slice of word objects belonging to this specific line
    for _ in line_tokens:
        if word_pointer < len(all_recognized_words):
            line_word_objects.append(all_recognized_words[word_pointer])
            word_pointer += 1
            
    if not line_word_objects:
        continue
        
    # Calculate base absolute boundaries
    line_start = line_word_objects[0]["start"]
    line_end = line_word_objects[-1]["end"]
    
    # Calculate word durations for statistical outlier analysis
    word_durations = [w["end"] - w["start"] for w in line_word_objects]
    
    # --- HEURISTIC 1: Fix Early Breath/Noise Triggers ---
    if len(line_word_objects) > 1:
        first_word_duration = word_durations[0]
        median_other_duration = np.median(word_durations[1:])
        
        # If the first word is abnormally long (e.g., 3x longer than the median word),
        # it likely caught pre-vocal breath noise. Clip it closer to the next word.
        if first_word_duration > (median_other_duration * 3.0) and first_word_duration > 1.5:
            # Shift the line start forward to the true phonetic onset
            line_start = line_word_objects[1]["start"] - min(0.3, median_other_duration)

    # --- HEURISTIC 2: Fix Vocal Tail Bloat (e.g., Extended Outro Ad-libs) ---
    if len(line_word_objects) > 1:
        last_word_duration = word_durations[-1]
        median_prev_duration = np.median(word_durations[:-1])
        
        # If the final word stretches out excessively compared to the rest of the line,
        # clamp its end time to prevent reverb trails from bloating the subtitle duration.
        if last_word_duration > (median_prev_duration * 2.5) and last_word_duration > 1.5:
            # Tighten the line end relative to when the final word actually peak-vocalized
            line_end = line_word_objects[-1]["start"] + max(1.0, median_prev_duration * 1.5)

    # --- HEURISTIC 3: Enforce 1-Second Minimum legibility duration ---
    if (line_end - line_start) < 1.0:
        line_end = line_start + 1.0
        
    # Safety gate to ensure end never precedes start after calculations
    if line_end <= line_start:
        line_end = line_start + 1.5

    event = pysubs2.SSAEvent(
        start=int(line_start * 1000), # Convert floats to milliseconds
        end=int(line_end * 1000),
        text=line
    )
    subs.append(event)

# 7. Save out generalized, polished subtitle track
subs.save(output_ass_file)
print(f"Successfully generated speech-aligned subtitles: {output_ass_file}")

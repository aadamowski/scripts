#!/usr/bin/env perl
#
# Description: Detects if the number of input lines per second exceeds a threshold and runs a notification command.
# Dependencies: perl
# Usage: cat large_file.log | ./input_rate_notifier.pl <rows_threshold> <seconds_threshold> '<notification_command>'
# Author: Aleksander Adamowski
#
# Options:
# - Rows threshold: The number of rows that triggers the check.
# - Seconds threshold: The time window in seconds.
# - Notification command: The command to run when threshold is exceeded.

use strict;
use warnings;

if (scalar(@ARGV) < 3) {
    die "Usage: $0 <rows_threshold> <seconds_threshold> '<notification_command'>\n";
}

my $row_count_threshold = $ARGV[0];
my $seconds_threshold = $ARGV[1];
my $notification_command = $ARGV[2];

my @queue = ();

# Track the last time a notification was sent to avoid spamming
my $last_notification_time = 0;

while (<STDIN>) {
    my $current_time = time;
    unshift @queue, $current_time;

    # If the queue exceeds the row count threshold, check the rate
    if (scalar(@queue) > $row_count_threshold) {
        pop @queue;
        
        # Time at the end of the queue
        my $tail_time = $queue[-1];
        
        # Time interval for the current window
        my $queue_interval = $current_time - $tail_time;
        
        # Check if the rate is exceeded and we are not spamming
        if ($queue_interval < $seconds_threshold && ($current_time - $last_notification_time) > $seconds_threshold) {
            system($notification_command) == 0
                or die "Error executing notification command: $!\n";
            $last_notification_time = $current_time;
        }
    }
}

#!/usr/bin/perl -w -p

BEGIN { use HTML::Entities; }
{
 $_ = encode_entities($_, '<>&"');
}

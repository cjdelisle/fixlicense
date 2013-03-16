#!/usr/bin/env perl
# You may redistribute this program and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
use strict;
use warnings;

my $orig = $_=
"You may redistribute this program and/or modify it under the terms of
the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.";

my $hash = $_;
$hash =~ s/^(.*)$/# $1/gm;

my $cstyle = $_;
$cstyle =~ s/^(.*)$/ * $1/gm;
$cstyle = "/*\n${cstyle}\n */";

sub read_file
{
    local $/;
    my $file = shift;
    open(FILE, $file) || die($!);
    my $content = <FILE>;
    close(FILE);
    return $content;
}

sub write_file
{
    local $/;
    my $file = shift;
    my $data = join("", @_);
    print("Fixing license typos in $file\n");
    open(FILE, ">$file") || die($!);
    print FILE $data;
    close(FILE);
}

sub looks_licensey
{
    my $data = lc(shift);
    if ($data =~ /license/m) { return 1; }
    if ($data =~ /without any warantee/m) { return 1; }
    if ($data =~ /copyright/m) { return 1; }
    return 0;
}

sub source
{
   my $path = shift;
   my $isPreHeader = shift;
   my $isHeader = shift;
   my $correctHeader = shift;

   my $data = read_file($path);
   my @lines = split("\n", $data);
   my @preHeader = ();
   my @header = ();
   my @content = ();
   my $state = 0;
   foreach (@lines) {
       if ($state < 2) {
           if ($isPreHeader->($_)) {
               $state = 1;
               push(@preHeader, $_);
           } elsif ($isHeader->($_)) {
               $state = 1;
               push(@header, $_);
           } elsif ($state == 1) {
               $state = 2;
               push(@content, $_);
           }
       } else {
           push(@content, $_);
       }
   }
   my @correctHeaderLines = split("\n", $correctHeader);
   for (my $i=0; $i < length(@correctHeaderLines); $i++) {
       if (!$header[$i] || $header[$i] ne $correctHeaderLines[$i]) {
           #print("$path has TYPOS!\n");
           my $ph = join("\n", @preHeader);
           my $con = join("\n", @content);
           my $hdr = join("\n", @header);
           if (!looks_licensey($hdr)) {
               # Put back whatever header they had after the license
               write_file($path, $ph, "\n", $correctHeader, "\n", $hdr, $con);
           } else {
               # obviously they made a mistake in their license header,
               # strip it and put the one they intended to use.
               write_file($path, $ph, "\n", $correctHeader, "\n", $con);
           }
           return;
       }
   }
   print("$path is fucking PERFECT!\n");
   return;
}

sub script
{
    my $path = shift;
    my $isPreHeader = sub { return $_[0] =~ /^#!/; };
    my $isHeader = sub { return $_[0] =~ /^\s*#.*/; };
    source($path, $isPreHeader, $isHeader, $hash);
}

sub license
{
   my $path = shift;
   my $data = read_file($path);
   my @lines = split("\n", $data);
   my @origLines = split("\n", $orig);
   if (length(@lines) == length(@origLines)) {
       for (my $i=0; $i<length(@lines); $i++) {
           if ($origLines[$i] ne $lines[$i]) {
               write_file($path, $orig);
               return;
           }
       }
   } else {
       write_file($path, $orig);
       return;
   }
   print("$path is fucking PERFECT!\n");
}

sub c
{
    my $path = shift;
    my $isPreHeader = sub { return $_[0] =~ /^\/\* vim:.*\*\//; };
    my $isHeader = sub { return $_[0] =~ /^\s*[\s\/]\*.*/ || $_[0] =~ /^\s*\/\/.*/; };
    source($path, $isPreHeader, $isHeader, $cstyle);
}

my %extensions = (
    '.pl'  => \&script,
    '.py'  => \&script,
    '.rb'  => \&script,
    '.sh'  => \&script,
    '.java'=> \&c,
    '.c'   => \&c,
    '.cpp' => \&c,
    '.cxx' => \&c,
    '.cc'  => \&c,
    '.js'  => \&c,
    '.go'  => \&c
);

my %licenseNames = map { $_ => 1 } (
    'copyright',
    'copying',
    'license',
    'license.md',
    'license.txt'
);


sub fix_file {
    my $path = shift;
    my $file = $path;
    $file =~ s/.*\/([^\/]*)$/$1/;

    if (exists($licenseNames{lc($file)})) {
        license($path);
        return;
    }

    my $ext = $file;
    $ext =~ s/.*(\.[^\.]*)$/$1/;
    #print "$file  $ext\n";
    my $func = $extensions{$ext};
    if ($func) {
        &{$func}($path);
    }
}

sub scan_dir {
    my $dir = shift;

    opendir(DIR, $dir) or die $!;
    my @f = grep { !/^\.{1,2}$/ } readdir (DIR);
    closedir(DIR);

    @f = grep {!/^.git/} @f;
    @f = map { $dir . '/' . $_ } @f;

    for my $file (@f) {
        if (-d $file) {
            scan_dir($file);
        } else {
            fix_file($file);
        }
    }
}
scan_dir('.');

#!/usr/bin/perl -w
# 
# Copyright (C) 2009-2011 Chris McClelland
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
use File::Temp qw/ tempdir /;
use FindBin '$Bin';
use File::Copy;
use File::Basename;
use Cwd;

if ( $#ARGV != 1 ) {
	print STDERR "Synopsis: $0 <headerFile> <htmlDir>\n";
	exit(1);
}

undef $/;
my $header = $ARGV[0];
my $htmlDir = $ARGV[1];
my $tempDir = tempdir("/tmp/XXXXXXX", CLEANUP => 1);
my $thisDir = getcwd;
my ($file, $baseName, $docFile, $srcFile, $desc);

# Copy Doxyfile over
copy("${Bin}/Doxyfile", "${tempDir}/Doxyfile") or die "Copy failed: $!";

# Copy header file, stripping DLLEXPORT and WARN_UNUSED_RESULT
open FILE, ${header} or die "Cannot open file";
$file = <FILE>;
close FILE;
$file =~ s/DLLEXPORT\(([^)]*)\)/${1}/imsg;
$file =~ s/ WARN_UNUSED_RESULT//imsg;
open FILE, ">${tempDir}/${header}" or die "Cannot open file";
print FILE $file;
close FILE;

chdir(${tempDir});
system("${Bin}/doxygen-*/bin/doxygen");
$baseName = basename(${header}, ".h")."_8h";
$docFile = "${tempDir}/html/${baseName}.html";
$srcFile = "${tempDir}/html/${baseName}_source.html";
chdir(${thisDir});

open FILE, ${docFile} or die "Cannot open file";
$file = <FILE>;
close FILE;

$file =~ s/<tr>[^\n]*?name=\"enum-members\".*?<\/tr>\n//ims;
$file =~ s/<tr>[^\n]*?name=\"func-members\".*?<\/tr>\n//ims;
$file =~ s/<hr\/>[^\n]*?<h2>Detailed Description<\/h2>\n(.*?<\/div>)//ims;
$desc = ${1};
$file =~ s/<table class="memberdecls">/${desc}\n<hr\/><h2>Overview<\/h2>\n<table class="memberdecls">/ims;
$file =~ s/<td class="paramtype">void&#160;<\/td>/<td class="paramtype">void<\/td>/ims;
$file =~ s/<h2><a name="define-members"><\/a>\nDefines<\/h2>/<div class="groupHeader">Defines<\/div>/ims;

open FILE, ">${htmlDir}/${baseName}.html" or die "Cannot open file";
print FILE ${file};
close FILE;

copy("${srcFile}", "${htmlDir}/") or die "Copy failed: $!";
copy("${tempDir}/html/doxygen.css", "${htmlDir}/") or die "Copy failed: $!";
copy("${tempDir}/html/doxygen.png", "${htmlDir}/") or die "Copy failed: $!";
copy("${tempDir}/html/tabs.css", "${htmlDir}/") or die "Copy failed: $!";

#!/usr/bin/env perl

use strict;
use Data::Dumper;
use Getopt::Long;

#my %codeColors =
#(
#    "0xFE06" => "#FC618D",
#    "0xFE07" => "#7BD88F",
#    "0xFE08" => "#FD9353",
#    "0xFE09" => "#948AE3",
#    "0xFE0A" => "#7F7D84",
#);

my %codeColors =
(
 "0xFE00" => "#7F7D84",
 "0xFE01" => "#FC618D",
 "0xFE02" => "#7BD88F",
 "0xFE03" => "#FCE566",
 "0xFE04" => "#FD9353",
 "0xFE05" => "#948AE3",
 "0xFE06" => "#5AD4E6",
 "0xFE07" => "#F7F1FF",

 "0xFE08" => "#D6D6D6",
 "0xFE09" => "#FC618D",
 "0xFE0A" => "#7BD88F",
 "0xFE0B" => "#FCE566",
 "0xFE0C" => "#FD9353",
 "0xFE0D" => "#948AE3",
 "0xFE0E" => "#00E5E5",
 "0xFE0F" => "#F7F1FF",
);

#7F7D84
#FC618D
#7BD88F
#FCE566
#FD9353
#948AE3
#5AD4E6
#F7F1FF

#D6D6D6
#FC618D
#7BD88F
#FCE566
#FD9353
#948AE3
#00E5E5
#F7F1FF

foreach my $fontName ("ColoredConsole-Bold")
{
    my $content = read_file('UTF-8', $fontName.".ttx");
    
    my @glypIds = $content =~ m~<GlyphID name="([^"\.]+)"/>~g;
    
#     die Dumper(\@glypIds);

    my $numPaletteEntries = keys %codeColors;
    
    my $extraGlyphIDs = "";
    my $extraMetrics = "";
    my $extraMaps = "";
    my $extraGlyphs = "";
    my $ligatureSets = "";
    my $colorGlyphs = "";
    my $colors = "";
    
    my $colorIndex = 0;
    foreach my $code (sort keys %codeColors)
    {
        $extraGlyphIDs .= sprintf qq(    <GlyphID name="%s"/>\n), $code;
        $extraMetrics .= sprintf qq(    <mtx name="%s" width="0" lsb="50"/>\n), $code;
        $extraMaps .= sprintf qq(    <map code="%s" name="%s"/>\n), $code, $code;
        $extraGlyphs .= sprintf qq(    <TTGlyph name="%s"/><!-- contains no outline data -->\n), $code;
        $colors .= sprintf qq(      <color index="%d" value="%s"/>\n), $colorIndex++, $codeColors{$code};
    }
    
    foreach my $glypId (@glypIds)
    {
        $ligatureSets .= sprintf qq(          <LigatureSet glyph="%s">\n), $glypId;
        my $colorIndex = 0;
        foreach my $code (sort keys %codeColors)
        {
            $extraGlyphIDs .= sprintf qq(    <GlyphID name="%s.%s"/>\n), $glypId, $code;
            $extraMetrics .= sprintf qq(    <mtx name="%s.%s" width="600" lsb="50"/>\n), $glypId, $code;
            $extraGlyphs .= sprintf qq(    <TTGlyph name="%s.%s"/><!-- contains no outline data -->\n), $glypId, $code;
            $ligatureSets .= sprintf qq(            <Ligature components="%s" glyph="%s.%s"/>\n), $code, $glypId, $code;
            $colorGlyphs .= sprintf qq(    <ColorGlyph name="%s.%s"><layer colorID="%d" name="%s"/></ColorGlyph>\n), $glypId, $code, $colorIndex++, $glypId;
        }
        $ligatureSets .= sprintf qq(          </LigatureSet>\n);
    }
    

    
    
    $content =~ s~    <!-- extra GlyphIDs -->\n~$extraGlyphIDs~;
    $content =~ s~    <!-- extra mtxs -->\n~$extraMetrics~;
    $content =~ s~    <!-- extra maps -->\n~$extraMaps~;
    $content =~ s~    <!-- extra TTGlyphs -->\n~$extraGlyphs~;
    $content =~ s~    <!-- LigatureSets -->\n~$ligatureSets~;
    $content =~ s~    <!-- ColorGlyphs -->\n~$colorGlyphs~;
    $content =~ s~      <!-- colors -->\n~$colors~;
    $content =~ s~<numPaletteEntries value="0"/>~<numPaletteEntries value="$numPaletteEntries"/>~;
    
    
    
    
    write_file('UTF-8', $fontName.".colored.ttx", $content);
    
    
    system "ttx", "-o", $fontName.".ttf", $fontName.".colored.ttx";
    
    
    
    
    
}




sub read_file
{
	my ($encoding, $path) = @_;
	open(my($file), '<:encoding('.$encoding.')', $path) || die "error $!: $path\n";
	my $content = "";
	while(<$file>) {
		$content .= $_;
	}
	close $file;
	return $content;
}

sub write_file
{
	my ($encoding, $path, $content) = @_;
	if (defined $content)
	{
		my $parentPath = $path;
		$parentPath =~ s!/?[^/]*$!!;
		
		if (length $parentPath && !-e $parentPath)
		{
			system "mkdir", "-p", $parentPath;
		}
	
		if (!-e $path || read_file($encoding, $path) ne $content)
		{
			open(my($file), '>:encoding('.$encoding.')', $path) || die "error $!: $path\n";
			print $file $content;
			close $file;
		}
	}
	elsif (-e $path)
	{
		system "rm", "-f", $path;
	}
}

#!/usr/bin/env perl
# File Name: vimbrowse.pl
# Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
# Last Update: September 17, 2004
###########################################################

use warnings;
use integer;
use File::Basename;
use File::Spec::Functions;

BEGIN {
    our $VERSION = 0.3;
    # Don't know where to look for gvim on windows - let's try the PATH
    our $VIM = $^O eq 'MSWin32' ? 'gvim' : '/usr/bin/gvim';
    $VIM = $ENV{'VIMBIN'} if $ENV{'VIMBIN'};
    # for some reason, gvim on windows doesn't like stdout, so we use vim 
    # instead of gvim to get the serverlist, which we assume to be in the 
    # same directory as gvim
    our $SERVERLIST = catfile(dirname($VIM), 'vim') . ' --serverlist';
    our $HOMEPAGE = $ENV{'HOMEPAGE'} || 'http://vim.sf.net/';
    our $SERVERNAME = 'VIMBROWSER';

    # analyze command line
    use Getopt::Long qw(:config gnu_getopt auto_version auto_help);
    use Pod::Usage;

    our $remote = '';
    our $vertical = 0;
    our $width = 0;
    our $height = 0;
    GetOptions(
        'remote=s' => \$remote,
        'columns|width=i' => \$width,
        'lines|height=i' => \$height,
        'vertical' => \$vertical,
        man => sub { pod2usage(-verbose => 2) });
}

sub sys {
    my $void = not defined wantarray;
    if ( $void ) {
        system(@_);
        return unless $?;
    } else {
        my @res = `@_`;
        return @res unless $?;
    }
    if ( $? == -1 ) {
        die "Failed to run @_: $!";
    } else {
        die "'@_' failed with status " . ( $? >> 8 );
    }
}

my $SplitCmd = 'BrowserSplit' . ($vertical ? '!' : '');
my $BrowseFirstCmd = $remote =~ /^[Ss]/o ? $SplitCmd : 'Browse';

my $VimOpts = '';
$VimOpts .= "lines=$height " if $height;
$VimOpts .= "columns=$width " if $width;

my @Instances = grep { /^$SERVERNAME/o } sys($SERVERLIST);
$remote = '' unless @Instances;
my %Instances;
@Instances{@Instances} = @Instances;

my $ServerName;
my $ExtraFirst = '';
if ( $remote ) {
    $ServerName = $SERVERNAME;
} else {
    unshift @ARGV, $HOMEPAGE unless @ARGV;
    sys("$VIM --servername $SERVERNAME");
    ( $ServerName ) = grep { /^$SERVERNAME/o and not $Instances{$_} } 
        sys($SERVERLIST) until defined $ServerName;
    chomp $ServerName;
    $ExtraFirst = ' | bw 1';
}

my $VimCmd = "$VIM --servername $ServerName --remote-send";

sys("$VimCmd ':set $VimOpts<CR>'") if $VimOpts; 

exit unless @ARGV;

sys("$VimCmd ':$BrowseFirstCmd " . shift(@ARGV) . "$ExtraFirst<CR>'");

foreach ( @ARGV ) {
    sleep 1;
    sys("$VimCmd ':$SplitCmd $_<CR>'");
}

__DATA__

# start of POD

=head1 NAME

vimbrowse.pl - use vim as a web browser from the command line

=head1 SYNOPSIS

B<vimbrowse.pl> B<--help>|B<--man>|B<--version>

B<vimbrowse.pl> [B<--(width|columns)=>I<num>] [B<--(height|lines)=>I<num>] 
[B<--remote={split,replace}>] [B<--vertical>] [I<uri1> I<uri2> ...]

=head1 OPTIONS

=over 4

=item B<--width=>I<num>

=item B<--columns=>I<num>

Set the number of columns to I<num>.

=item B<--height=>I<num>

=item B<--lines=>I<num>

Set the height of the window to I<num> lines.

=item B<--remote={split,replace}>

Find an existing vim browser window and use it. If the value is C<split>, a 
new browser window will be opened (in the existing vim window). Otherwise, 
the first argument will be opened in the existing window. In fact, only the 
first letter (C<s> or C<r>) is important, and is case insensitive. If the 
option is not given, or there is no open vim browser, a new gvim instance 
will be started.

=item B<--vertical>

If the option is given, use vertical split instead of horizontal. This 
affects both the behaviour of C<--remote=split>, and when more than one 
argument is given.

=item B<--help>

Give a short usage message and exit with status 0

=item B<--man>

Give the full description and exit with status 1

=item B<--version>

Print a line with the program name and exit with status 0

=back

=head1 ARGUMENTS

Each argument is used as a uri, using the same conventions as the first 
argument of the B<:Browse> command of the browser plugin.

=head1 DESCRIPTION

This script invokes C<vim(1)> in a web browser mode. It requires the browser 
plugin. If an argument is given, it will be opened as a uri, as described 
above. If several arguments are given, each uri will get its own (vim) 
window. If no argument is given and B<--remote> is specified, the only 
(possible) effect is changing the size of the existing vim browser window. If 
B<--remote> is not specified (or there is no existing window), opens the uri 
in I<$HOMEPAGE>.

Examples:

    vimbrowse.pl        # open the home page in a new vim
    vimbrowse.pl --remote=split --vertical www.gnu.org
                        # open the gnu homepage in the same vim,
                        # in a new window split vertically
    vimbrowse.pl --remote=replace www.google.com vim.sf.net
                        # replace that page by google search, and
                        # add also the vim page, spliting horizontally
    vimbrowse.pl --remote=s --width=120
                        # change the width of the browser

=head1 ENVIRONMENT

The following environment variables affect the operation of the script:

=over

=item I<$HOMEPAGE>

The page to open when no argument is given.

=item I<$VIMBIN>

The full path of the gvim binary. By default, F</usr/bin/gvim> is used.

=back

=head1 SEE ALSO

B<vim(1)>, L<http://vim.sf.net>

This script is part of the B<browser> plugin for vim, 
L<http://vim.sf.net/scripts/script.php?script_id=1053>. See
C<:help browser.vim> for the documentation of the plugin.

=head1 AUTHOR

Moshe Kaminsky <kaminsky@math.huji.ac.il> - Copyright (c) 2004

=cut


#!/usr/bin/env perl
# File Name: vimbrowse.pl
# Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
# Last Update: Tue 15 Mar 2005 11:38:42 AM IST
###########################################################

use warnings;
use integer;
use File::Basename;
use File::Spec::Functions;
use Carp;

BEGIN {

    our $VERSION = 1.1;
    sub broken { $^O eq 'MSWin32' } 

    #our $VIM = broken() ? 'vim' : '/usr/bin/vim';
    our $VIM = 'vim';
    $VIM = $ENV{'VIMBIN'} if $ENV{'VIMBIN'};
    our $SERVERLIST = "$VIM --serverlist";
    our $HOMEPAGE = $ENV{'HOMEPAGE'} || 'http://vim.sf.net/';
    our $SERVERNAME = 'VIMBROWSER';

    # analyze command line
    use Getopt::Long qw(:config gnu_getopt);
    use Pod::Usage;

    our $remote = '';
    our $vertical = 0;
    our $width = 0;
    our $height = 0;
    our $gui = ($0 =~ /gvimbrowse(\..*)?$/o);
    GetOptions(
        'remote=s' => \$remote,
        'columns|width=i' => \$width,
        'lines|height=i' => \$height,
        'vertical' => \$vertical,
        'gui|g!' => \$gui,
        man => sub { pod2usage(-verbose => 2) },
        help => sub { pod2usage(-verbose => 1) },
        version => sub { print basename($0) . " version $VERSION\n"; exit 0 },
    );
    $VIM = 'start ' . $VIM if ($gui and broken());
    $VIM =~ s/(vim(\..*)?)$/g$1/o if $gui;
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

# windows doesn't like single quotes. *sigh*
my $q = broken() ? '"' : "'";
my $ServerName;
my $ExtraFirst = '';
if ( $remote ) {
    chomp($ServerName = $Instances[-1]);
} else {
    $ExtraFirst = ' | bw 1';
    if ( $gui ) {
        sys("$VIM --servername $SERVERNAME");
        ( $ServerName ) = grep { /^$SERVERNAME/o and not $Instances{$_} } 
            sys($SERVERLIST) until defined $ServerName;
        chomp $ServerName;
    } else {
        chomp(my $first = shift || '');
        $VIM .= " --servername $SERVERNAME";
        $VIM .= " -c ${q}set $VimOpts$q" if $VimOpts;
        my $cmd = "$VIM -c $q$BrowseFirstCmd $first $ExtraFirst$q" . 
                  join('', map { chomp;" -c $q$SplitCmd $_$q" } @ARGV);
        exec $cmd;
    }
}

my $VimCmd = "$VIM --servername $ServerName --remote-send";

sys("$VimCmd $q:set $VimOpts<CR>$q") if $VimOpts; 

chomp(my $first = shift || '');
sys("$VimCmd $q:$BrowseFirstCmd $first $ExtraFirst<CR>$q");

foreach ( @ARGV ) {
    sleep 1;
    chomp;
    sys("$VimCmd $q:$SplitCmd $_<CR>$q");
}

__DATA__

# start of POD

=head1 NAME

vimbrowse, gvimbrowse - use vim as a web browser from the command line

=head1 SYNOPSIS

B<vimbrowse> B<--help>|B<--man>|B<--version>

B<vimbrowse> [B<--gui>|B<-g>] [B<--(width|columns)=>I<num>] 
[B<--(height|lines)=>I<num>] [B<--remote={split,replace}>] [B<--vertical>] 
[I<uri1> I<uri2> ...]

=head1 OPTIONS

=over 4

=item B<--gui>, B<-g>

Run the gui vim (gvim) rather than the terminal based one. The same effect is 
acheived if the script name starts with B<gvimbrowse>.

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

This script invokes C<vim(1)> in a web browser mode. It requires the 
B<browser> plugin, and vim compiled with I<+clientserver>. If an argument is 
given, it will be opened as a uri, as described above. If several arguments 
are given,each uri will get its own (vim) window. If no argument is given and 
B<--remote> is specified, the only (possible) effect is changing the size of 
the existing vim browser window. If B<--remote> is not specified (or there is 
no existing window), opens a browser window as if the I<:Browse> command was 
given with no arguments.

If the program name start with F<gvimbrowse>, or the B<-g> or B<--gui> switch 
is given, opens the gui vim version (gvim). Otherwise, uses the terminal 
version.

Examples:

    gvimbrowse        # open the home page in a new vim
    gvimbrowse --remote=split --vertical www.gnu.org
                        # open the gnu homepage in the same vim,
                        # in a new window split vertically
    gvimbrowse --remote=replace www.google.com vim.sf.net
                        # replace that page by google search, and
                        # add also the vim page, spliting horizontally
    gvimbrowse --remote=s --width=120
                        # change the width of the browser

=head1 ENVIRONMENT

The only variable used explicitly in the script is

=over

=item I<$VIMBIN>

The vim binary. By default, F<vim> is used.

=back

Several other variable affect the plugin behaviour, though, as described in 
the help for the plugin.

=head1 SEE ALSO

B<vim(1)>, L<http://vim.sf.net>

This script is part of the B<browser> plugin for vim, 
L<http://vim.sf.net/scripts/script.php?script_id=1053>. See
C<:help browser.vim> for the documentation of the plugin.

=head1 AUTHOR

Moshe Kaminsky <kaminsky@math.huji.ac.il> - Copyright (c) 2004

=cut


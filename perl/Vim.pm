# File Name: Vim.pm
# Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
# Last Update: September 26, 2004
###########################################################

package VIM::Tie::Option;
use base 'Tie::Hash';

sub TIEHASH {
    bless {} => shift;
}

sub FETCH {
    my $res = VIM::Eval('&' . $_[1]);
}

sub STORE {
    my ($self, $Opt, $Value) = @_;
    $Value = "'$Value'" unless $Value+0 eq $Value;
    VIM::DoCommand('let &' . "$Opt=$Value");
}

package VIM::Tie::Vars;
use base 'Tie::Hash';

sub TIEHASH {
    bless {} => shift;
}

sub FETCH {
    my $res = $_[0]->EXISTS($_[1]) ? VIM::Eval($_[1]) : undef;
}

sub STORE {
    my ($self, $Var, $Value) = @_;
    $Value = "'$Value'" unless $Value+0 eq $Value;
    VIM::DoCommand("let $Var=$Value");
}

sub EXISTS {
    my $res = VIM::Eval("exists('$_[1]')");
}

sub DELETE {
    VIM::DoCommand("unlet! $_[1]");
}

package VIM::Scalar;
use base 'Tie::Scalar';
use Carp;

sub TIESCALAR {
    my ($class, $var, $default, $sub) = @_;
    croak 'Must supply the name of a vim variable' unless $var;
    croak "Third argument must be a code ref" 
        if (defined $sub and ref($sub) ne 'CODE');
    my $self = { 
        var => $var,
        default => $default,
        'sub' => $sub || sub { $_[0] },
    };
    bless $self => $class;
}

sub FETCH {
    my $self = shift;
    my $res = $Vim::Variable{$self->{'var'}};
    $res = $self->{'default'} unless defined $res;
    &{$self->{'sub'}}($res);
}

sub STORE {
    my ($self, $val) = @_;
    $Vim::Variable{$self->{'var'}} = $val;
}

package Vim;
use base 'Exporter';

our @EXPORT_OK = qw(%Option %Variable error warning msg ask debug bufWidth 
                    cursor fileEscape);

BEGIN {
    our $VERSION = 0.4;
}

tie our %Option, 'VIM::Tie::Option';
tie our %Variable, 'VIM::Tie::Vars';

sub error {
    VIM::Msg("@_", 'ErrorMsg');
}

sub warning {
    VIM::Msg("@_", 'WarningMsg');
}

sub msg {
    VIM::Msg("@_", 'Type');
}

sub ask {
    my $vimCmd = $Option{'guioptions'} =~ /c/ ? 'input' : 'inputdialog';
    my $res = VIM::Eval("$vimCmd(" . join(',', map { "'$_'" } @_) . ')');
}

sub debug {
    my $msg = shift;
    my $verbose = shift || 1;
    my ($pack, $file, $line, $sub) = caller(1);
    ($pack, $file, $line) = caller;
    msg("$sub($line): $msg") if $Option{'verbose'} >= $verbose;
}

sub bufWidth {
    my $width = $Option{'textwidth'};
    $width = $Option{'columns'} - $Option{'wrapmargin'} unless $width;
    $width;
}

# get/set the cursor position in characters. Thanks to Antoine J. Mechelynck 
# for the idea.
sub cursor {
    # get the current position
    my ($row, $col) = $main::curwin->Cursor();
    my $line = $main::curbuf->Get($row);
    use bytes;
    my $part = substr($line, 0, $col);
    no bytes;
    $col = length($part);
    if ( @_ ) {
        my ($new_r, $new_c) = @_;
        $line = $main::curbuf->Get($new_r);
        $part = substr($line, 0, $new_c);
        use bytes;
        $new_c = length($part);
        no bytes;
        $main::curwin->Cursor($new_r, $new_c);
    }
    return ($row, $col);
}

sub fileEscape {
    local $_ = shift;
    s/([?:%#])/\\$1/go;
    tr/?/%/ if $^O eq 'MSWin32';
    $_
}
    

__DATA__

# start of POD

=head1 NAME

Vim - General utilities when using perl from within I<vim>

=head1 SYNOPSIS

    perl <<EOF
    use Vim qw(%Option msg ask);

    $Option{'filetype'} = 'perl'; # set the filetype option
    $lines = $Vim::Variable{'b:foo'}; 
                        # get the value of the b:foo variable

    msg('perl is nice');
    $file = ask('Which file to erase?', '/usr/bin/emacs');

    tie $vimbin, 'VIM::Scalar',
        'g:vim_bin',                    # vim name of the variable
        'gvim',                         # default value
        sub { '/usr/bin/' . shift };    # add path to the value
    EOF

=head1 DESCRIPTION

This is a small module with utility functions for easier access to vim's 
facilities when working with perl. It provides the following exportable 
utilities:

=over

=item VIM::Scalar

A class to tie a perl variable to a vim variable. Reading the value of the 
will read the current value of the vim variable, and setting it will set the 
vim variable. The syntax is

C<tie $var, 'VIM::Scalar',> B<vim-var>[, B<default>[, B<sub>]]

Where I<$var> is the perl variable, B<vim-var> is a string containing the 
name of the vim variable, B<default>, if given is the value I<$var> will have 
if there is no vim variable by this name (if B<default> is not given, I<$var> 
will be C<undef> in this situation), and B<sub>, if given, is a sub ref that 
will be applied to the value (whether it comes from an actual vim variable, 
or the default value). The sub should accept the value, and return a modified 
value.

=item %Option

A (magical) hash to set and get the values of vim options. When setting, the 
value is treated as a string unless it is numeric. Thus

        $Option{'lines'} = 30;

and

        $Option{'filetype'} = 'perl';

will both work, but

        $Option{'backupext'} = '1';

will not.

=item %Variable

A hash to set and get values of vim variables. Any legal vim variable name 
can be used (include C<b:> prefixes, etc.). When getting the value of a 
variable that does not exist, the result is C<undef>. The same rules apply 
with regard to string and numeric values as for options.

S<C<delete $Variable{'b:foo'}> > will unlet the variable, 
S<C<exists $Variable{'s:bar'}> > checks if the variable is defined.

=item msg(), warning(), error()

Produce the given message, warning or error. Any number of arguments are 
allowed, and they are concatenated.

=item ask()

ask the user a question. The arguments and their meaning are the same as for 
vim's I<input()> function. The function will call I<input()> or  
I<inputdialog> depending on the C<c> option in B<guioptions>.

=item debug()

Produce the message given in the first argument, but only if the value of the 
C<verbose> option is at least the second argument (1 by default).

=item bufWidth()

Returns the current buffer width according to the settings of B<textwidth> 
and B<wrapmargin>

=item cursor()

Similar to C<$curwin-E<gt>Cursor>, and has the same signature, but works in 
characters and not bytes.

=item fileEscape()

Escape characters in the given expression, so that the result can be used as 
a plain file name in vim.

=back

=head1 AUTHOR

Moshe Kaminsky <kaminsky@math.huji.ac.il> - Copyright (c) 2004

=cut


# File Name: Vim.pm
# Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
# Last Update: September 03, 2004
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

package VIM::Tie::Var;
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

package Vim;
use base 'Exporter';

our @EXPORT_OK = qw(%Option %Variable error warning msg ask debug);

BEGIN {
    our $VERSION = 0.2;
}

tie our %Option, 'VIM::Tie::Option';
tie our %Variable, 'VIM::Tie::Var';

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
    my $res = VIM::Eval('input(' . join(',', map { "'$_'" } @_) . ')');
}

sub debug {
    my $msg = shift;
    my $verbose = shift || 1;
    msg($msg) if $Option{'verbose'} >= $verbose;
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

=head1 DESCRIPTION

This is a small module with utility functions for easier access to vim's 
facilities when working with perl. It provides the following exportable 
utilities:

=over

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
vim's I<input()> function.

=item debug()

Produce the message given in the first argument, but only if the value of the 
C<verbose> option is at least the second argument (1 by default).

=back

=head1 AUTHOR

Moshe Kaminsky <kaminsky@math.huji.ac.il> - Copyright (c) 2004

=cut

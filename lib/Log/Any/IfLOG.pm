package Log::Any::IfLOG;

# DATE
# VERSION

sub import {
    my $self = shift;

    my $caller = caller();
    if ($ENV{LOG}) {
        require Log::Any;
        Log::Any->_export_to_caller($caller, @_);
    } else {
        my $saw_log_param = grep { $_ eq '$log' } @_;
        if ($saw_log_param) {
            *{"$caller\::log"} = \Object::Dumb->new;
        }
    }
}

package
    Object::Dumb;
sub new { my $o = ""; bless \$o, shift }
sub AUTOLOAD { 0 }

1;
# ABSTRACT: Load Log::Any only if LOG environment variable is true

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::Any::IfLOG '$log';


=head1 DESCRIPTION

This module will load L<Log::Any> only when C<LOG> environment variable is true.
Otherwise, the module is not loaded and if user imports C<$log>, a dumb object
will be returned instead that will accept any method but return false.

This is a quick-hack solution to avoid the cost of loading Log::Any under
"normal condition" (when C<LOG> is not set to true). Since Log::Any 1.00,
startup overhead increases to about 7ms on my PC (from under 1ms for the
previous version). Since I want to keep startup overhead of CLI apps under 50ms
(see L<Perinci::CmdLine::Lite>) to keep tab completion from getting a noticeable
lag, every millisecond counts.


=head1 ENVIRONMENT

=head2 LOG => bool

If set to true, will load Log::Any as usual. Otherwise, won't load Log::Any and
will return a dumb object in C<$log> instead.


=head1 SEE ALSO

L<Log::Any>

L<http://github.com/dagolden/Log-Any/issues/24>

=cut

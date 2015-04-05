package Log::Any::IfLOG;

# DATE
# VERSION

my $log_singleton;

our $ENABLE_LOG;

sub import {
    my $self = shift;

    my $log_enabled;
    if (defined $ENABLE_LOG) {
        $log_enabled = $ENABLE_LOG;
    } elsif ($INC{'Log/Any.pm'}) {
        # Log::Any has been loaded, so we have absorbed the cost anyway
        $log_enabled = 1;
    } else {
        $log_enabled =
            $ENV{LOG} || $ENV{TRACE} || $ENV{DEBUG} ||
            $ENV{VERBOSE} || $ENV{QUIET} || $ENV{LOG_LEVEL};
    }

    if ($log_enabled) {
        require Log::Any;
        my $caller = caller();
        Log::Any->_export_to_caller($caller, @_);
    } else {
        my $saw_log_param = grep { $_ eq '$log' } @_;
        if ($saw_log_param) {
            if (!$log_singleton) { $log_singleton = Object::Dumb->new }
            *{"$caller\::log"} = \$log_singleton;
        }
    }
}

package
    Object::Dumb;
sub new { my $o = ""; bless \$o, shift }
sub AUTOLOAD { 0 }

1;
# ABSTRACT: Load Log::Any only if log-related environment variables are set

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::Any::IfLOG '$log';


=head1 DESCRIPTION

This module will load L<Log::Any> only when C<LOG> environment variable is true
(or C<TRACE>, or C<DEBUG>, or C<VERBOSE>, or C<QUIET>, or C<LOG_LEVEL>; these
variables are used by L<Perinci::CmdLine>). Otherwise, the module is not loaded
and if user imports C<$log>, a dumb object will be returned instead that will
accept any method but return false.

This is a quick-hack solution to avoid the cost of loading Log::Any under
"normal condition" (when log-enabling variables/flags are not set to true).
Since Log::Any 1.00, startup overhead increases to about 7-10ms on my PC/laptop
(from under 1ms for the previous version). Since I want to keep startup overhead
of CLI apps under 50ms (see L<Perinci::CmdLine::Lite>) to keep tab completion
from getting a noticeable lag, every millisecond counts.


=head1 ENVIRONMENT

=head2 LOG => bool

If set to true, will load Log::Any as usual. Otherwise, won't load Log::Any and
will return a dumb object in C<$log> instead.

=head2 TRACE => bool

=head2 DEBUG => bool

=head2 VERBOSE => bool

=head2 QUIET => bool

=head2 LOG_LEVEL => str

These variables are used by L<Perinci::CmdLine> as a shortcut to set log level.
The setting of these variables indicate that user wants to see some logging, so
Log::Any will be loaded under the presence of these variables.


=head1 VARIABLES

=head2 $ENABLE_LOG => bool

This setting can be forced to force loading Log::Any or not.


=head1 SEE ALSO

L<Log::Any>

L<http://github.com/dagolden/Log-Any/issues/24>

=cut

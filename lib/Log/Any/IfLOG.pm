package Log::Any::IfLOG;

# DATE
# VERSION

my $log_singleton;

our $DEBUG;
our $ENABLE_LOG;

sub __init_log_singleton {
    if (!$log_singleton) { $log_singleton = Object::Dumb->new }
}

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
    #warn "D:log_enabled: $log_enabled" if $DEBUG;

    my $caller = caller();
    if ($log_enabled) {
        require Log::Any;
        Log::Any->_export_to_caller($caller, @_);
    } else {
        my $saw_log_param = grep { $_ eq '$log' } @_;
        if ($saw_log_param) {
            __init_log_singleton();
            *{"$caller\::log"} = \$log_singleton;
        }
    }
}

sub get_logger {
    __init_log_singleton();
    $log_singleton;
}

package
    Object::Dumb;
sub new { my $o = ""; bless \$o, shift }
sub AUTOLOAD { 0 }

1;
# ABSTRACT: Load Log::Any only if "logging is enabled"

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::Any::IfLOG '$log';


=head1 DESCRIPTION

This module is a drop-in replacement/wrapper for L<Log::Any> to be used from
your modules. This is a quick-hack solution to avoid the cost of loading
Log::Any under "normal condition". Since Log::Any 1.00, startup overhead
increases to about 7-10ms on my PC/laptop (from under 1ms for the previous
version). Because I want to keep startup overhead of CLI apps under 50ms (see
L<Perinci::CmdLine::Lite>) to keep tab completion from getting a noticeable lag,
every millisecond counts.

This module will only load L<Log::Any> when "logging is enabled". Otherwise, it
will just return without loading anything. If C<$log> is requested in import, a
fake object is returned that responds to methods like C<debug>, C<is_debug> and
so on but will do nothing when called and just return 0.

To determine "logging is enabled":

=over

=item * Is $ENABLE_LOG defined?

This package variable can be used to force "logging enabled" (if true) or
"logging disabled" (if false). Normally, you don't need to do this except for
testing.

=item * Is Log::Any is already loaded (from %INC)?

If Log::Any is already loaded, it means we have taken the overhead hit anyway so
logging is enabled.

=item * Is one of log-related environment variables true?

If one of L<LOG>, C<TRACE>, or C<DEBUG>, or C<VERBOSE>, or C<QUIET>, or
C<LOG_LEVEL> is true then logging is enabled. These variables are used by
L<Perinci::CmdLine>.

Otherwise, logging is disabled.

=back


=head1 ENVIRONMENT

=head2 LOG => bool

=head2 TRACE => bool

=head2 DEBUG => bool

=head2 VERBOSE => bool

=head2 QUIET => bool

=head2 LOG_LEVEL => str


=head1 VARIABLES

=head2 $ENABLE_LOG => bool

This setting can be forced to force loading Log::Any or not.


=head1 SEE ALSO

L<Log::Any>

L<http://github.com/dagolden/Log-Any/issues/24>

=cut

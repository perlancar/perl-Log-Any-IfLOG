package Log::Any::IfLOG;

# DATE
# VERSION

sub import {
    if ($ENV{LOG}) {
        require Log::Any;
        Log::Any->import;
    } else {
        my $self = shift;
        my $saw_log_param = grep { $_ eq '$log' } @_;
        if ($saw_log_param) {
            my $caller = caller();
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
"normal condition" (when C<LOG> is not set to true).


=head1 ENVIRONMENT

=head2 LOG => bool

If set to true, will load Log::Any as usual. Otherwise, won't load Log::Any and
will return a dumb object in C<$log> instead.


=head1 SEE ALSO

L<Log::Any>

L<http://github.com/dagolden/Log-Any/issues/24>

=cut

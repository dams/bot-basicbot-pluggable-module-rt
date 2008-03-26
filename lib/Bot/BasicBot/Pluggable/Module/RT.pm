package Bot::BasicBot::Pluggable::Module::RT;

use strict;

use vars qw( @ISA $VERSION );
@ISA     = qw(Bot::BasicBot::Pluggable::Module);
$VERSION = '0.03';

use RT::Client::REST;
use RT::Client::REST::Ticket;

sub init {
    my ($self) = @_;

    # default value for vars.
    foreach (qw(user_server user_login user_password)) {
        next if $self->get($_);
        $self->set($_, '** SET ME **')
   }
   defined $self->get('user_output')
       or $self->set('user_output', 'RT %id: %s - %S');
   defined $self->get('user_regexp')
       or $self->set('user_regexp', '(?:^|\s)rt\s*#?\s*(\d+)');
}

my $rt_handler;
my $connected = 0;

sub told {
    my ( $self, $mess ) = @_;
    my $bot = $self->bot();

    my $body = $mess->{body};

    my $regexp = $self->get('user_regexp');

    my ($nb) = $body =~ /$regexp/i
        or return;

    if (!$connected) {
        $rt_handler = RT::Client::REST->new(server => $self->get('user_server'));
        $rt_handler->login(
            username => $self->get('user_login'),
            password => $self->get('user_password')
        );
        $connected = 1;
    }

    my $ticket = RT::Client::REST::Ticket->new(
        rt  => $rt_handler,
        id  => $nb,
    );
    return unless defined $ticket;

    $ticket->retrieve();
    my %fields = (
        '%i' => $ticket->id(),
	'%q' => $ticket->queue(),
	'%c' => $ticket->creator(),
	'%s' => $ticket->subject(),
	'%S' => $ticket->status(),
	'%p' => $ticket->priority(),
	'%C' => $ticket->created(),
    );

    my $output = $self->get('user_output');
    while (my ($k, $v) = each(%fields)) {
        $output =~ s/\Q$k\E/$v/g;
    }
    return $output;
}

sub help { q(catch anything that looks like an RT number : /RT#?\s*(\d+)/i. it requires the RT server url, a login and password. Set them using '!set RT server', '!set RT login', '!set RT password'. The information displayed can be configured by setting the output string : '!set RT output some_string'. in the string, you can use the following placeholders :
%i : id of the ticket
%q : queue of the ticket
%c : creator of the ticket
%s : subject of the ticket
%S : status of the ticket
%p : priotity of the ticket
%C : time where it was created
Default is : 'RT %i: %s - %S';

The matching can be configured using : '!set RT regexp some_regexp'. The default is (?:^|\s)rt\s*#?\s*(\d+) .

You nee to have the Vars module loaded before setting keys.
) }

1;

__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::RT - Retrieves information of RT tickets

=head1 SYNOPSIS

    < you> RT#12345
    < bot> RT 12345: there is a bug in the matrix! - open

=head1 DESCRIPTION

This module uses RT::Client::REST::Ticket to connect to a RT server and grab
information on tickets.

=head1 IRC USAGE

See synopsis

=head1 VARS

=over

=item server

The url of the RT server. Set it using:

  !set RT server <url>

=item login

The login to use. Set it using:

  !set RT login <login>

=item password

The password to use. Set it using:

  !set RT password <password>

=item output

The output format the bot should use to display information. Set it using:

  !set RT output <output_string>. 

the string can contain the following placeholders :

  %i : id of the ticket
  %q : queue of the ticket
  %c : creator of the ticket
  %s : subject of the ticket
  %S : status of the ticket
  %p : priotity of the ticket
  %C : time where it was created

Default is : 'RT %id: %s - %S';

=item regexp

The regexp that is used to extract the rt number from the body. Set it using:

  !set RT regexp <some_regexp>.

Its first match should be the rt number.
Default is (?:^|\s)rt\s*#?\s*(\d+)

=back

=head1 AUTHOR

Damien "dams" Krotkine, C<< <dams@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-bot-basicbot-pluggable-module-rt@rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/>. I will be notified, and
then you'll automatically be notified of progress on your bug as I
make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Damien "dams" Krotkine, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

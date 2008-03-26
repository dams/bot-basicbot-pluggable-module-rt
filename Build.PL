use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name       => "Bot::BasicBot::Pluggable::Module::RT",
    license           => 'perl',
    dist_author       => q{Damien "dams" Krotkine <dams@cpan.org>},
    dist_version_from => 'lib/Bot/BasicBot/Pluggable/Module/RT.pm',
    requires      => {
        'Test::More'               => 0,
        'Bot::BasicBot::Pluggable' => '0.5',
        'RT::Client::REST' => 0,
	'RT::Client::REST::Ticket' => 0,
    },
    add_to_cleanup => ['Bot-BasicBot-Pluggable-Module-RT-*'],
);

$build->create_build_script;


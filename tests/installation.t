use strict;
use utf8;
use warnings;

use Test::More;

use HTTP::Tiny;
use IO::Pty;
use IPC::Run qw( finish pump run start );

my $show_output = $ENV{SHOW_OUTPUT};

# FIXME: Probably should do this using just Perl rather than a shell command
my $columns = `tput cols`;
my $lines = `tput lines`;

# Helpful wrapper around IPC::Run's pump()
sub _pump {
    my ($h) = @_; # Output is supposed to be passed as the second parameter

    # Clear previous output
    $_[1] = '';

    my $result = $h->pump();
    
    print $_[1] if $show_output;

    return $result;
}

subtest 'Installation succeeds on CentOS 8' => sub {
    my ($in, $out);

    my $h = start(
        [ '../run-in-container.sh', 'test-centos-8' ],
        '<pty<', \$in,
        '>pty>', \$out,
    );

    $h->{PTYS}{0}->set_winsize($lines, $columns);

    _pump($h, $out) until $out =~ /Press .*? to start installation/;
    # Enter to start installation
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install Perl/;
    # Enter to install Perl
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install Apache/;
    # Enter to install Apache
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install MariaDB/;
    # Enter to install MariaDB
    $in = "\n";

    _pump($h, $out) until $out =~ /installer has set the MariaDB/ &&
        $out =~ / .*?root.*? user password/;
    # Enter to acknowledge MariaDB password
    $in = "\n";

    _pump($h, $out) until $out =~ /Enter new password for/;
    # Superuser password
    $in = "test\n";

    _pump($h, $out) until $out =~ /Enter new password again/;
    # Superuser password repeated
    $in = "test\n";

    _pump($h, $out) until $out =~ /Installation completed/;
    _pump($h, $out) until $out =~ /(?<url>https?:\/\/\S+\/otrs\/index\.pl)/;

    like($+{url}, qr{^http://.*?/otrs/index.pl$},
        'Installation returns the application URL');

    test_login($+{url});

    # Enter to exit installation
    $in = "\n";
    $h->pump();

    $h->finish();
};

subtest 'Installation succeeds on Ubuntu 20.04' => sub {
    my ($in, $out);

    my $h = start(
        [ '../run-in-container.sh', 'test-ubuntu-20-04' ],
        '<pty<', \$in,
        '>pty>', \$out,
    );

    $h->{PTYS}{0}->set_winsize($lines, $columns);

    _pump($h, $out) until $out =~ /Press .*? to start installation/;
    # Enter to start installation
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install Apache/;
    # Enter to install Apache
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install MariaDB/;
    # Enter to install MariaDB
    $in = "\n";

    _pump($h, $out) until $out =~ /installer has set the MariaDB/ &&
        $out =~ / .*?root.*? user password/;
    # Enter to acknowledge MariaDB password
    $in = "\n";

    _pump($h, $out) until $out =~ /Enter new password for/;
    # Superuser password
    $in = "test\n";

    _pump($h, $out) until $out =~ /Enter new password again/;
    # Superuser password repeated
    $in = "test\n";

    _pump($h, $out) until $out =~ /Installation completed/;
    _pump($h, $out) until $out =~ /(?<url>https?:\/\/\S+\/otrs\/index\.pl)/;

    like($+{url}, qr{^http://.*?/otrs/index.pl$},
        'Installation returns the application URL');

    test_login($+{url});

    # Enter to exit installation
    $in = "\n";
    $h->pump();

    $h->finish();
};

subtest 'Installation succeeds on Ubuntu 21.04' => sub {
    my ($in, $out);

    my $h = start(
        [ '../run-in-container.sh', 'test-ubuntu-21-04' ],
        '<pty<', \$in,
        '>pty>', \$out,
    );

    $h->{PTYS}{0}->set_winsize($lines, $columns);

    _pump($h, $out) until $out =~ /Press .*? to start installation/;
    # Enter to start installation
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install Apache/;
    # Enter to install Apache
    $in = "\n";

    _pump($h, $out) until $out =~ /Press .*? to install MariaDB/;
    # Enter to install MariaDB
    $in = "\n";

    _pump($h, $out) until $out =~ /installer has set the MariaDB/ &&
        $out =~ / .*?root.*? user password/;
    # Enter to acknowledge MariaDB password
    $in = "\n";

    _pump($h, $out) until $out =~ /Enter new password for/;
    # Superuser password
    $in = "test\n";

    _pump($h, $out) until $out =~ /Enter new password again/;
    # Superuser password repeated
    $in = "test\n";

    _pump($h, $out) until $out =~ /Installation completed/;
    _pump($h, $out) until $out =~ /(?<url>https?:\/\/\S+\/otrs\/index\.pl)/;

    like($+{url}, qr{^http://.*?/otrs/index.pl$},
        'Installation returns the application URL');

    test_login($+{url});

    # Enter to exit installation
    $in = "\n";
    $h->pump();

    $h->finish();
};

sub test_login {
    my ($url) = @_;

    my $http = HTTP::Tiny->new;
    my $response;

    $response = $http->get($url);

    is($response->{status}, 200,
        'Opening the application URL results in a successful response');
    
    # Grab the generated challenge token (in an ugly regexpy way)
    $response->{content} =~ m{name="ChallengeToken" value="(.*?)"};
    my $challenge_token = $1;

    $response = $http->post_form($url, {
        ChallengeToken => $challenge_token,
        Action         => 'Login',
        User           => 'root@localhost',
        Password       => 'test',
    });

    like($response->{status}, qr/200|302/,
        'Submitting the login form results in a successful response');

    if ($response->{status} eq '302') {
        # The location to redirect to is relative to root server URL
        (my $root_url = $url) =~ s{^ (https?://[^/]+) .* $}{$1}x;
        $response = $http->get($root_url . $response->{headers}{location});
    }

    ok(index($response->{content}, 'You are logged in as') >= 0,
        'Response contains text indicating login was successful');
}

done_testing;

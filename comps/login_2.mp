has 'username';
has 'password';

use Icemaker::Internal::Login;

method handle() {
    my $session = $m->session;
    if ( $.username and $.password ) {
        if ( Icemaker::Internal::Login::valid_password($.password) ) {
            # Check if credentials match
            if ( Icemaker::Internal::Login->login($.username,$.password) ) {
                $session->{logged_in} = 1;
                Icemaker::Internal::Session->load_user_session($m,$.username);
                $m->redirect('/home');

            # Check if user want to reset password instead
            } elsif ( my $user = Icemaker::Internal::User->get_user_by_username($.username) ) {
                if ( defined $user and defined $user->{password} and length($user->{password}) == 0 ) {
                    Icemaker::Internal::Login->set_password($.username,$.password);
                    $session->{message} = "Your new password has been set. Please log in with it.";
                    $m->redirect('/login');
                }
            }
        } else {
            $session->{message} = 'Passwords must have at least 6 chars and contain at least one of these: #!$%&/';
            $m->redirect('/login');
        } 
    }
    $session->{message} = "Please supply username and password.";
    $m->redirect('/login');
}

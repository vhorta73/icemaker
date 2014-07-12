<%init>
    use Icemaker::Internal::Login;
    Icemaker::Internal::Login->logout($m);
    $m->redirect('/login');
</%init>


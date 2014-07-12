% if ( $msg ) { 
<div id='message'><% $msg %></div> 
% }
<form action='/login_2' method=post>
 <div id='center-dialog-box'>
  <div id='inside'>
   <p align='center'>Username
   <input name='username' type='text' size=30>
   <p align='center'>Password
   <input name='password' type='password' size=30>
   <p align='center'><input type=submit value="Log in">
  </div>
 </div>
</form>

<%init>
    my $msg = $m->session->{message};
</%init>


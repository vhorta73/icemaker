<style>
#left-nav {
 position: absolute; left: 0; top: 10%; float:left; width: 10%; height: 90%; 
 background-color: #600; box-shadow: 10px 4px 5px #DDDDDD; z-index: 2;
}
#header-nav {
 position: absolute; left: 0; top: 0; width: 100%; height: 10%;
 background-color: #600; box-shadow: 10px 10px 5px #DDDDDD; z-index: 1;
}
#right-nav {
 position: absolute; top: 10%; left: 10%; float: right; width: 90%; height: 90%;
 z-index: 0; background-color: #fff;
}
ul.vert-one{
 margin:0; padding:0; list-style-type:none; display:block;
 font:bold 12px Helvetica, Verdana, Arial, sans-serif; line-height:200%; width:100%;
}
ul.vert-one li{
 margin:0; padding:0; border-top: 1px solid #4D0000;
}
ul.vert-one li a{
 display:block; text-decoration:none; color:#fff; background:#600;
 padding:0 0 0 7%; width:93%;
}
ul.vert-one li a:hover{
 background:#900;
}
ul.vert-one li a.current, a.current:hover{
 font:bold 12px Helvetica, Verdana, Arial, sans-serif;
 list-style-type:none; display:block; line-height:200%; width:93%; background:#933;
}
#subtitle {
 font: bold 12px Helvetica, Verdana, Arial, sans-serif; color: #fa0; bottom: -5px;
 list-style-type:none; display:block; line-height:200%; position: relative;
}
#logout {
 margin:0; padding:0; list-style-type:none;
 text-decoration:none; font:bold 12px Helvetica, Verdana, Arial, sans-serif; line-height:200%;
 color: white; position: absolute; right: 5px; top: 5px; background:#600; text-align:right;
}
#greeting {
 color: yellow; text-align:left;
}
</style>

<%class>
    has 's';
</%class>

<form action='/home' method=post>
 <input name='s' value='<% $s %>' type='hidden'>
 <div id='header-nav'>
   <div id='greeting'>Welcome back, <% $m->session->{user_data}->{name} %></div>
   <a id='logout' href="/logout" <% $current->{logout} %>>Logout</a>
 </div>
 <div id='left-nav'>
  <ul class="vert-one">
   <li></li>
   <span id='subtitle'>RECIPE</span>
   <li><a href="/home?s=recipeorders" <% $current->{recipeorders} %>>Order</a></li>
   <li><a href="/home?s=recipeorderqueue" <% $current->{recipeorderqueue} %>>Queue</a></li>
   <li><a href="/home?s=recipedailyproduction" <% $current->{recipedailyproduction} %>>Daily Production</a></li>
   <li><a href="/home?s=recipestocklevels" <% $current->{recipestocklevels} %>>Stock Levels</a></li>
% #   <li><a href="/home?s=dailyproduction" <% $current->{dailyproduction} %>>Daily Production</a></li>
% #   <li><a href="/home?s=reports" <% $current->{reports} %>>Reporting</a></li>
% #   <li><a href="/home?s=logging" <% $current->{logging} %>>Logging</a></li>
   <li></li>
   <span id='subtitle'>SETUP</span>
% if ( $user_access->can('recipes') ) {
   <li><a href="/home?s=recipes" <% $current->{recipes} %>>Recipes</a></li>
% }
% if ( $user_access->can('ingredients') ) {
   <li><a href="/home?s=ingredients" <% $current->{ingredients} %>>Ingredients</a></li>
% }
% if ( $user_access->can('packages') ) {
   <li><a href="/home?s=packages" <% $current->{packages} %>>Packages</a></li>
% }
% if ( $user_access->can('machines') ) {
   <li><a href="/home?s=machines" <% $current->{machines} %>>Machines</a></li>
% }
% # if ( $user_access->can('customers', 2) ) {
   <li><a href="/home?s=customers" <% $current->{customers} %>>Customers</a></li>
% # }
% if ( $user_access->can('suppliers') ) {
   <li><a href="/home?s=suppliers" <% $current->{suppliers} %>>Suppliers</a></li>
% }
% if ( $user_access->can('users', 2) ) {
   <li><a href="/home?s=users" <% $current->{users} %>>Users</a></li>
% }
% #   <li></li>
% #   <span id='subtitle'>ORDERS</span>
% #   <li><a href="/home?s=orderrecipes" <% $current->{orderrecipes} %>>Recipes</a></li>
% #   <li><a href="/home?s=orderingredients" <% $current->{orderingredients} %>>Ingredients</a></li>
% #   <li><a href="/home?s=orderpackaging" <% $current->{orderpackaging} %>>Packaging</a></li>
% #   <li></li>
% #   <span id='subtitle'>STOCK</span>
% #   <li><a href="/home?s=recipesstock" <% $current->{recipesstock} %>>Recipes</a></li>
% #   <li><a href="/home?s=ingredientsstock" <% $current->{ingredientsstock} %>>Ingredients</a></li>
% #   <li><a href="/home?s=packagingstock" <% $current->{packagingstock} %>>Packaging</a></li>
    <li></li>
   </ul>
 </div>

 <div id='right-nav'>
% # with chosen tab, get respective tool
% if ( $s and length($s) > 0 ) {
    <& '/home/index.mi' &>
% }
 </div>

</form>


<%init>
    my $logged_in = $m->session->{logged_in};
    $m->redirect('/login') if !$logged_in;
 
    my $s = $m->request_args()->{s};
    my $current = $s ? { $s => "class='current'" } : {};
    my $user_access = $m->session()->{user_access};
</%init>

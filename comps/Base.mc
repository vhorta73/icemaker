<%class>
has 'title' => (default => 'Icemaker');
</%class>

<%augment wrap>
  <html>
    <head>
      <link rel="stylesheet" href="/static/css/style.css">
    </head>
    <body>
      <% inner() %>
    </body>
  </html>
</%augment>


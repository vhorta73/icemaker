<%class>
has 'title' => (default => 'Icemaker');
</%class>

<%augment wrap>
  <html>
    <head>
      <link rel="stylesheet" href="/static/css/style.css">
      <script type="text/javascript" src="/static/js/d3.min.js"></script>
    </head>
    <body>
      <% inner() %>
    </body>
  </html>
</%augment>


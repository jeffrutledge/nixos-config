{ pkgs, colors }:

pkgs.writeText "startpage.html" ''
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <style>
      body {
        background-color: ${colors.base03};
        margin: 0;
      }
    </style>
  </head>
  <body>
  </body>
  </html>
''

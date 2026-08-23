{ pkgs, colors }:

pkgs.runCommand "startpage" { } ''
  mkdir -p $out
  cat > $out/index.html <<EOF
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <title>Startpage</title>
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
  EOF
''

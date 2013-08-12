htpasswd-editor
===============

htpasswd-editor is a simple Perl CGI to manage htpasswd files.

License
=======

MIT

It's an evolution of: http://www.perlmonks.org/?node_id=178482

Description
===========

htpasswd-editor is a simple Perl CGI to manage htpasswd files. It permits to add, list or remove users, 
it also permits an authentificated user to change his password. It can be useful for adding basic access 
control management to a static website (ex: documentation generated from Markdown, Rst, Rdoc...).

<img height="400" src="https://raw.github.com/kakwa/htpasswd-editor/master/images/htpasswd_pl.jpg"/>

Deployment
==========

* Create an htpasswd file:
```
> htpasswd -c </path/to/htpasswd> <initial user>
```

* Change the file's rights:
```
> chown www-data|apache2|httpd </path/to/htpasswd>
> chmod 600 </path/to/htpasswd>
```

* deploy the htpasswd.pl
```
cp htpasswd.pl </path/to/cgi-dir>
chmod 755 </path/to/cgi-dir>/htpasswd.pl
```

* edit the ```settings``` hash at the begin of htpasswd.pl and change the entries ```dir``` and ```htpasswd```.
```
vim </path/to/cgi-dir>/htpasswd.pl
```

* add the following configuration inside your vhost (htpasswd.pl is protected by the htpasswd it manages):
```
  ScriptAlias /cgi-bin/ </path/to/cgi-dir>
  <Directory "</path/to/cgi-dir>">
        AllowOverride None
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        Order allow,deny
        Allow from all
        AuthName "restrict posting"
        AuthType Basic
        AuthUserFile </path/to/htpasswd>
        require valid-user
  </Directory>
```

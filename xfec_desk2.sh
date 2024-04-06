#!/bin/bash

test ! -d $HOME/.vnc &&  mkdir -p $HOME/.vnc

VNCPASS=$(echo $RANDOM | md5sum | tr -d -- -)
echo "$VNCPASS" | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

VNCDISPLAY=$(($(id -u) + 1000))
export DISPLAY=":$VNCDISPLAY"

mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

echo "#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
" > $HOME/.vnc/xstartup
chmod +x $HOME/.vnc/xstartup

vncserver -kill :$VNCDISPLAY &>/dev/null
rm -fv $HOME/.vnc/*.{log,pid} $HOME/.ICEauthority $HOME/.Xauthority /tmp/.X$VNCDISPLAY-lock /tmp/.X11-unix/X$VNCDISPLAY


WEBVNC=$((8900+$VNCDISPLAY)) #Se crea la variable para el websocket (con el id de usuario se crea el puerto del socket)
VNCSERVER=$((5900+$VNCDISPLAY)) #Se crea tambien el puerto del servidor donde se aloja el servidor
vncserver :$VNCDISPLAY -desktop "Desktop $USER"  -localhost  \

echo "[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=amyserver
Group=amyserver
WorkingDirectory=/home/amyserver

PIDFile=/home/amyserver/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/vncserver@.service

echo $?
sleep 5s
pgrep -lf tigervnc -u $USER  #pgrep sirve para mostrar el id de un proceso, con -lf se muestra el nombre con el pid
# y las coincidencias de la linea de comandos, en este caso elproceso es tigervnc -u  del usuario
if [ $? -gt 0 ]; then  #Si no existe el directorio $HOME/.vnc mandara el error
echo "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ERROR EN EL COMANDO:
vncserver :$VNCDISPLAY -desktop \"Desktop $USER\"  -localhost -AlwaysShared -AcceptKeyEvents \
    -AcceptPointerEvents -AcceptSetDesktopSize -SendCutText -AcceptCutText -autokill

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "
exit 1
else  #Si existe el directorio entonces

pstree -u $USER   #Muestra los procesos del usuario como un arbol, con -u se muestran las transiciones
#de los procesos

fi
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
URL para conexión de usuario $USER:

Se recomienda ejecutar dentro de una sesión \"screen\" o \"tmux\".

Para terminar la sesión VNC presionar Ctrl+C.

https://172.27.43.121:$WEBVNC/vnc.html/$SLURM_JOBID/$USER/$(hostname -i)/$WEBVNC/$VNCPASS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

webpath=$(which websockify)

$webpath $WEBVNC 127.0.0.1:$VNCSERVER
#Se busca el programa websockify para redirigir el puerto VNCSERVER al socket WEBVNC

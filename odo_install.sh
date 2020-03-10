#! / bin / bash
################################################## ##############################
# Script para instalar Odoo en Ubuntu 14.04, 15.04, 16.04 y 18.04 (también podría usarse para otra versión)
# Autor: Yenthe Van Ginneken
# ------------------------------------------------- ------------------------------
# Este script instalará Odoo en su servidor Ubuntu 16.04. Puede instalar varias instancias de Odoo
# en un Ubuntu debido a los diferentes xmlrpc_ports
# ------------------------------------------------- ------------------------------
# Crea un nuevo archivo:
# sudo nano odo-install.sh
# Coloque este contenido en él y luego haga que el archivo sea ejecutable:
# sudo chmod + x odo-install.sh
# Ejecute el script para instalar Odoo:
# ./odo-install
################################################## ##############################

OE_USER = "odoo"
OE_HOME = "/ $ OE_USER"
OE_HOME_EXT = "/ $ OE_USER / $ {OE_USER} -server"
# El puerto predeterminado donde se ejecutará esta instancia de Odoo (siempre que use el comando -c en el terminal)
# Establezca en verdadero si desea instalarlo, falso si no lo necesita o ya lo tiene instalado.
INSTALL_WKHTMLTOPDF = "True"
# Establezca el puerto Odoo predeterminado (aún debe usar -c /etc/odoo-server.conf, por ejemplo, para usar esto).
OE_PORT = "8069"
# Elija la versión de Odoo que desea instalar. Por ejemplo: 12.0, 11.0, 10.0 o saas-18. Cuando se usa 'master', se instalará la versión master.
# ¡IMPORTANTE! Este script contiene bibliotecas adicionales que son específicamente necesarias para Odoo 12.0
OE_VERSION = "12.0"
# ¡Establezca esto en True si desea instalar la versión empresarial de Odoo!
IS_ENTERPRISE = "False"
# establecer la contraseña superadmin
OE_SUPERADMIN = "admin"
OE_CONFIG = "$ {OE_USER} -server"

##
### Enlaces de descarga de WKHTMLTOPDF
## === Ubuntu Trusty x64 y x32 === (para otras distribuciones, reemplace estos dos enlaces,
## para tener instalada la versión correcta de wkhtmltopdf, para una nota de peligro consulte 
## https://github.com/odoo/odoo/wiki/Wkhtmltopdf):
WKHTMLTOX_X64 = https: //github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb
WKHTMLTOX_X32 = https: //github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.trusty_i386.deb

# ------------------------------------------------- -
# Servidor de actualización
# ------------------------------------------------- -
echo -e "\ n ---- Actualizar servidor ----"

# add-apt-repository puede instalar add-apt-repository Ubuntu 18.x
sudo apt-get install software-properties-common
# el paquete de universo es para Ubuntu 18.x
sudo add-apt-repository universe
# libpng12-0 dependencia para wkhtmltopdf
sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"
sudo apt-get update
sudo apt-get upgrade -y

# ------------------------------------------------- -
# Instalar el servidor PostgreSQL
# ------------------------------------------------- -
echo -e "\ n ---- Instalar el servidor PostgreSQL ----"
sudo apt-get install postgresql -y

echo -e "\ n ---- Creando el usuario ODOO PostgreSQL ----"
sudo su - postgres -c "createuser -s $ OE_USER" 2> / dev / null || cierto

# ------------------------------------------------- -
# Instalar dependencias
# ------------------------------------------------- -
echo -e "\ n --- Instalación de Python 3 + pip3 -"
sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libpng12-0 gdebi -y

echo -e "\ n ---- Instalar paquetes / requisitos de python ----"
sudo pip3 install -r https://github.com/odoo/odoo/raw/${OE_VERSION}/requirements.txt

echo -e "\ n ---- Instalación de nodeJS NPM y rtlcss para soporte LTR ----"
sudo apt-get install nodejs npm
sudo npm install -g rtlcss

# ------------------------------------------------- -
# Instale Wkhtmltopdf si es necesario
# ------------------------------------------------- -
if [$ INSTALL_WKHTMLTOPDF = "True"]; luego
  echo -e "\ n ---- Instale wkhtml y coloque accesos directos en el lugar correcto para ODOO 12 ----"
  # Recoja la correcta de las versiones x64 y x32:
  if ["` getconf LONG_BIT` "==" 64 "]; entonces
      _url = $ WKHTMLTOX_X64
  más
      _url = $ WKHTMLTOX_X32
  fi
  sudo wget $ _url
  sudo gdebi --n `basename $ _url`
  sudo ln -s / usr / local / bin / wkhtmltopdf / usr / bin
  sudo ln -s / usr / local / bin / wkhtmltoimage / usr / bin
más
  echo "¡Wkhtmltopdf no está instalado debido a la elección del usuario!"
fi

echo -e "\ n ---- Crear usuario del sistema ODOO ----"
sudo adduser --system --quiet --shell = / bin / bash --home = $ OE_HOME --gecos 'ODOO' --group $ OE_USER
# El usuario también debe agregarse al grupo sudo'ers.
sudo adduser $ OE_USER sudo

echo -e "\ n ---- Crear directorio de registro ----"
sudo mkdir / var / log / $ OE_USER
sudo chown $ OE_USER: $ OE_USER / var / log / $ OE_USER

# ------------------------------------------------- -
# Instalar ODOO
# ------------------------------------------------- -
echo -e "\ n ==== Instalación del servidor ODOO ===="
sudo git clone --depth 1 --branch $ OE_VERSION https://www.github.com/odoo/odoo $ OE_HOME_EXT /

si [$ IS_ENTERPRISE = "True"]; luego
    # ¡Instalación de Odoo Enterprise!
    echo -e "\ n --- Crear enlace simbólico para nodo"
    sudo ln -s / usr / bin / nodejs / usr / bin / node
    sudo su $ OE_USER -c "mkdir $ OE_HOME / enterprise"
    sudo su $ OE_USER -c "mkdir $ OE_HOME / enterprise / addons"

    GITHUB_RESPONSE = $ (sudo git clone --depth 1 --branch $ OE_VERSION https://www.github.com/odoo/enterprise "$ OE_HOME / enterprise / addons" 2> & 1)
    mientras que [[$ GITHUB_RESPONSE == * "Autenticación" *]]; hacer
        echo "------------------------ ADVERTENCIA ----------------------- ------- "
        echo "¡Tu autenticación con Github ha fallado! Inténtalo de nuevo".
        printf "Para clonar e instalar la versión empresarial de Odoo, necesita ser un socio oficial de Odoo y necesita acceso a \ nhttp: //github.com/odoo/enterprise. \ n"
        echo "SUGERENCIA: presione ctrl + c para detener este script".
        eco "------------------------------------------------ ------------- "
        eco " "
        GITHUB_RESPONSE = $ (sudo git clone --depth 1 --branch $ OE_VERSION https://www.github.com/odoo/enterprise "$ OE_HOME / enterprise / addons" 2> & 1)
    hecho

    echo -e "\ n ---- Código empresarial agregado en $ OE_HOME / enterprise / addons ----"
    echo -e "\ n ---- Instalación de bibliotecas específicas de la empresa ----"
    sudo pip3 instalar num2words ofxparse
    sudo npm install -g less
    sudo npm install -g less-plugin-clean-css
fi

echo -e "\ n ---- Crear directorio de módulo personalizado ----"
sudo su $ OE_USER -c "mkdir $ OE_HOME / custom"
sudo su $ OE_USER -c "mkdir $ OE_HOME / custom / addons"

echo -e "\ n ---- Configuración de permisos en la carpeta de inicio ----"
sudo chown -R $ OE_USER: $ OE_USER $ OE_HOME / *

echo -e "* Crear archivo de configuración del servidor"

sudo touch /etc/${OE_CONFIG}.conf
echo -e "* Creando el archivo de configuración del servidor"
sudo su root -c "printf '[opciones] \ n; Esta es la contraseña que permite las operaciones de la base de datos: \ n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = $ {OE_SUPERADMIN} \ n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_port = $ {OE_PORT} \ n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "archivo de registro printf '= /var/log/${OE_USER}/${OE_CONFIG}.log\n' >> /etc/${OE_CONFIG}.conf"
si [$ IS_ENTERPRISE = "True"]; luego
    sudo su root -c "printf 'addons_path = $ {OE_HOME} / enterprise / addons, $ {OE_HOME_EXT} / addons \ n' >> /etc/${OE_CONFIG}.conf"
más
    sudo su root -c "printf 'addons_path = $ {OE_HOME_EXT} / addons, $ {OE_HOME} / custom / addons \ n' >> /etc/${OE_CONFIG}.conf"
fi
sudo chown $ OE_USER: $ OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Crear archivo de inicio"
sudo su root -c "echo '#! / bin / sh' >> $ OE_HOME_EXT / start.sh"
sudo su root -c "echo 'sudo -u $ OE_USER $ OE_HOME_EXT / openerp-server --config = / etc / $ {OE_CONFIG} .conf' >> $ OE_HOME_EXT / start.sh"
sudo chmod 755 $ OE_HOME_EXT / start.sh

# ------------------------------------------------- -
# Agregar ODOO como un demonio (initscript)
# ------------------------------------------------- -

echo -e "* Crear archivo de inicio"
gato << EOF> ~ / $ OE_CONFIG
#! / bin / sh
### COMIENCE LA INFORMACIÓN DE INICIO
# Proporciona: $ OE_CONFIG
# Inicio obligatorio: \ $ remote_fs \ $ syslog
# Parada obligatoria: \ $ remote_fs \ $ syslog
# Debe comenzar: \ $ red
# Debe parar: \ $ red
# Inicio predeterminado: 2 3 4 5
# Detener por defecto: 0 1 6
# Descripción breve: aplicaciones empresariales empresariales
# Descripción: Aplicaciones comerciales de ODOO
### END INIT INFO
RUTA = / bin: / sbin: / usr / bin
DAEMON = $ OE_HOME_EXT / odoo-bin
NOMBRE = $ OE_CONFIG
DESC = $ OE_CONFIG
# Especifique el nombre de usuario (predeterminado: odoo).
USUARIO = $ OE_USER
# Especifique un archivo de configuración alternativo (Predeterminado: /etc/openerp-server.conf).
CONFIGFILE = "/ etc / $ {OE_CONFIG} .conf"
# pidfile
PIDFILE = / var / run / \ $ {NAME} .pid
# Opciones adicionales que se pasan al Daemon.
DAEMON_OPTS = "- c \ $ CONFIGFILE"
[-x \ $ DAEMON] || salida 0
[-f \ $ CONFIGFILE] || salida 0
checkpid () {
[-f \ $ PIDFILE] || volver 1
pid = \ `cat \ $ PIDFILE \`
[-d / proc / \ $ pid] && return 0
volver 1
}
caso "\ $ {1}" en
comienzo)
echo -n "Comenzando \ $ {DESC}:"
start-stop-daemon --start --quiet --pidfile \ $ PIDFILE \
--chuid \ $ USER --background --make-pidfile \
--exec \ $ DAEMON - \ $ DAEMON_OPTS
echo "\ $ {NOMBRE}".
;;
detener)
echo -n "Deteniendo \ $ {DESC}:"
start-stop-daemon --stop --quiet --pidfile \ $ PIDFILE \
--oknodo
echo "\ $ {NOMBRE}".
;;
reiniciar | forzar-recargar)
echo -n "Reiniciando \ $ {DESC}:"
start-stop-daemon --stop --quiet --pidfile \ $ PIDFILE \
--oknodo
dormir 1
start-stop-daemon --start --quiet --pidfile \ $ PIDFILE \
--chuid \ $ USER --background --make-pidfile \
--exec \ $ DAEMON - \ $ DAEMON_OPTS
echo "\ $ {NOMBRE}".
;;
*)
N = / etc / init.d / \ $ NAME
echo "Uso: \ $ NAME {start | stop | restart | force-reload}"> & 2
salida 1
;;
esac
salida 0
EOF

echo -e "* Archivo de inicio de seguridad"
sudo mv ~ / $ OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
raíz de sudo chown: /etc/init.d/$OE_CONFIG

echo -e "* Iniciar ODOO al iniciar"
sudo update-rc.d $ OE_CONFIG por defecto

echo -e "* Iniciando el servicio Odoo"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
eco "------------------------------------------------ ----------- "
echo "¡Listo! El servidor Odoo está en funcionamiento. Especificaciones:"
echo "Puerto: $ OE_PORT"
echo "Servicio de usuario: $ OE_USER"
echo "Usuario PostgreSQL: $ OE_USER"
echo "Ubicación del código: $ OE_USER"
echo "Carpeta de complementos: $ OE_USER / $ OE_CONFIG / addons /"
echo "Iniciar servicio Odoo: servicio sudo $ OE_CONFIG start"
echo "Detener el servicio Odoo: sudo service $ OE_CONFIG stop"
echo "Reiniciar el servicio Odoo: sudo service $ OE_CONFIG restart"
eco "------------------------------------------------ ----------- "
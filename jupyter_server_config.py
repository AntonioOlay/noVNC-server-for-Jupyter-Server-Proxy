import os

uid=os.getuid()

WEBSOCKET=8900+1000+uid
print(WEBSOCKET)

c.ServerProxy.servers = {
           'noVNC': {
                   'command': ['/home/amyserver/xfec_desk3.sh'],
                    'timeout': 30,
                    'port': WEBSOCKET,
                    'absolute_url': False,
                    'launcher_entry': {
                        'title': 'noVNC'
               }
          }
    }

import os
import os.path

uid=os.getuid()

WEBSOCKET=8900+1000+uid
print(WEBSOCKET)

xfec_path = os.path.abspath("xfec_desk3.sh")

c.ServerProxy.servers = {
           'noVNC': {
                   'command': [xfec_path],
                    'timeout': 30,
                    'port': WEBSOCKET,
                    'absolute_url': False,
                    'launcher_entry': {
                        'title': 'noVNC'
               }
          }
    }

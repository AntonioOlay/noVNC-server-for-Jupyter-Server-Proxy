import setuptools

setuptools.setup(
    name="jupyter-noVNC-server",
              # py_modules rather than packages, since we only have 1 file
    py_modules=["noVNC"],
    entry_points={
        "jupyter_serverproxy_servers": [
                                              # name = packagename:function_name         
            "noVNC = noVNC:setup_noVNC",
        ]
    },
    install_requires=["jupyter-server-proxy"],
)                       

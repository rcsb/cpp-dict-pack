class DictConfig(object):
    """Class describing the configuration of dictionaries"""

    # These need to be in sync with Dict2XMLSchema.csh
    # prefix -- base of XSD file
    # url -- how to download dictionary
    # ns (not used yet)
    # dname (not used yet)
    __dictmap = {
        "mmcif_ddl": {
            "prefix": "mmcif_ddl",
            "ns": "mmcif_ddl",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_ddl/master/dist/mmcif_ddl.dic"
        },
        "mmcif_pdbx_v5_next": {
            "prefix": "pdbx-v50-next",
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/dist/mmcif_pdbx_v5_next.dic"

        },
        "mmcif_pdbx_v50": {
            "prefix": "pdbx-v50",
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/dist/mmcif_pdbx_v50.dic"
        },
        "mmcif_pdbx_v40": {
            "prefix": "pdbx-v40",
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/previous/dist/mmcif_pdbx_v40.dic",
            "suppress_xml": True  # We were not producing xml schema - probably v41.
        },
        "mmcif_pdbx_v41": {
            "prefix": "pdbx-v40",  # Not sure why this is v40 instead of v41
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/previous/dist/mmcif_pdbx_v41.dic"
        },
        "mmcif_pdbx_v42": {
            "prefix": "pdbx-v42",
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/previous/dist/mmcif_pdbx_v42.dic"
        },
        "mmcif_pdbx_v31": {
            "prefix": "pdbx",
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/previous/dist/mmcif_pdbx_v31.dic"
        },
        "mmcif_pdbx_v32": {
            "prefix": "pdbx-v32",
            "ns": "PDBx",
            "dName": "mmcif_pdbx",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/previous/dist/mmcif_pdbx_v32.dic"
        },
        "mmcif_ihm": {
            "prefix": "mmcif_ihm",
            "ns": "mmcif_ihm",
            "dName": "ihm-extension",
            "url": "https://raw.githubusercontent.com/ihmwg/IHM-dictionary/master/ihm-extension.dic",
            "suppress_xml": True
        },
        "mmcif_pdbx_vrpt": {
            "prefix": "mmcif_pdbx_vrpt",
            "ns": "mmcif_pdbx_vrpt",
            "dName": "mmcif_pdbx_vrpt",
            "url": "https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx_vrpt/master/dist/mmcif_pdbx_vrpt.dic",
            "suppress_xml": True
        },
        "mmcif_ma": {
            "url": "https://raw.githubusercontent.com/ihmwg/MA-dictionary/master/mmcif_ma.dic",
            "suppress_xml": True
        }
    }

    def get_prefix(self, dname):
        if dname in self.__dictmap:
            return self.__dictmap[dname]["prefix"]
        return None

    def get_url(self, dname):
        if dname in self.__dictmap:
            return self.__dictmap[dname]["url"]
        return None

    def should_suppress_xml(self, dname):
        if dname in self.__dictmap:
            val = self.__dictmap[dname].get("suppress_xml", False)
            return val
        return None

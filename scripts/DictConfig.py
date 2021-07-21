class DictConfig(object):
    """Class describing the configuration of dictionaries"""

    # These need to be un sync with
    __dictmap = {
        "mmcif_pdbx_v32": {
            "prefix": "pdbx-v32",
            "ns": "PDBx",
            "dName": "mmcif_pdbx"
        },
        "mmcif_ddl": {
            "prefix": "mmcif_ddl",
            "ns": "mmcif_ddl"
        },
        "mmcif_pdbx_v5_next": {
            "prefix": "pdbx-v50-next",
            "ns": "PDBx",
            "dName": "mmcif_pdbx"
        },
        "mmcif_pdbx_v50": {
            "prefix": "pdbx-v50",
            "ns": "PDBx",
            "dName": "mmcif_pdbx"
        }

    }

    def getPrefix(self, dname):
        if dname in self.__dictmap:
            return self.__dictmap[dname]["prefix"]
        return None

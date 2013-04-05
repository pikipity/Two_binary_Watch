from distutils.core import setup
import py2exe

setup(windows=["Sync_with_computer.pyw",{"script":"Sync_with_computer.pyw","icon_resources":[(1,"icon//Sync_icon.ico")]}],data_files=[\
    ("icon",["icon//Sync_icon.ico"])])

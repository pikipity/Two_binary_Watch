import Tkinter
import ttk
import serial
import tkMessageBox
import time

def Wrong_window(wrong_message):
    tkMessageBox.showwarning("Wrong",wrong_message)

def sync():
    checkwrong=0
    Com_number=com_number.get()
    if(ser.isOpen()):
        Wrong_window("This COM has been used. Please Close it first.")
    else:
        Com_number=int(Com_number[4])-1
        boudrate_num=2400
        ser.baudrate=boudrate_num
        ser.port=Com_number
        ser.timeout=1
        try:
            ser.open()
        except serial.SerialException:
            Wrong_window("There is something wrong for your %s. Please check this COM port. "\
                         %com_number.get())
            checkwrong=1
        if(checkwrong==0):
            hour=time.strftime('%H',time.localtime(time.time()))
            minute=time.strftime('%M',time.localtime(time.time()))
            second=int(time.strftime('%S',time.localtime(time.time())))+3
            if (second>=60):
                second=second-60
            second=str(second)
            if (len(second)==1):
                second='0'+second
            ser.write(hour[0])
            time.sleep(0.5)
            ser.write(hour[1])
            time.sleep(0.5)
            ser.write(minute[0])
            time.sleep(0.5)
            ser.write(minute[1])
            time.sleep(0.5)
            ser.write(second[0])
            time.sleep(0.5)
            ser.write(second[1])
            time.sleep(0.5)
            ser.close()
        
def ForHelp():
    HelpWindow=Tkinter.Toplevel()
    HelpWindow.title("Help")
    HelpWindow.iconbitmap("icon/Sync_icon.ico")
    Help_Content=Tkinter.Message(HelpWindow,text="""This program is very easy.

First, Connect our binary watch to your computer.

Second, Choose the COM port that the binary watch uses.

Third, Click the \"Sync\" button. After a few seconds, this sync process will be finished.

Our Program will use 2400bps 8N1 speed to transmmit the data.

If you have any question or find any Bugs, please feel free to contact me. You can go to my blog -- \"pikipity.github.com\" or send me email -- \"pikipityw@gmail.com\" to contact me."""\
                                 ,font="Times 12 bold",width=430).pack()
    
    

if(__name__=="__main__"):
    root=Tkinter.Tk()
    root.title("Sync Machine")
    root.iconbitmap("icon/Sync_icon.ico")
    
    label_com=Tkinter.Label(root,text="COM Number: ",font="Times 23 bold").grid(row=0,column=0)
    com_number=Tkinter.StringVar()
    com_number.set("COM 2")

    ComPort=[]
    for x in xrange(1,21):
        PortName="COM "+str(x)
        ComPort.append(PortName)
    
    manul_com=ttk.Combobox(root,text=com_number,values=ComPort,font="Times 23 bold").grid(\
                                                          row=0,column=1)

    ser=serial.Serial()
    button_sync=Tkinter.Button(root,text="Sync",command=sync,font="Times 18 bold",width=20).grid(row=1,\
                                                      column=0)

    button_help=Tkinter.Button(root,text="Help",command=ForHelp,font="Times 18 bold",width=24).grid(row=1,column=1)

    root.mainloop()

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
        Wrong_window("This COM has been used")
    else:
        Com_number=int(Com_number[4])-1
        boudrate_num=2400
        ser.baudrate=boudrate_num
        ser.port=Com_number
        ser.timeout=1
        try:
            ser.open()
        except serial.SerialException:
            Wrong_window("There is something wrong for your %s"%com_number.get())
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
        
    
    

if(__name__=="__main__"):
    root=Tkinter.Tk()
    root.title("Sync Machine")
    
    label_com=Tkinter.Label(root,text="COM Number: ").grid(row=0,column=0)
    com_number=Tkinter.StringVar()
    com_number.set("COM 2")
    manul_com=ttk.Combobox(root,text=com_number,values=["COM 1","COM 2"\
                                                      ,"COM 3","COM 4"\
                                                      ,"COM 5"]).grid(\
                                                          row=0,column=1)

    ser=serial.Serial()
    button_sync=Tkinter.Button(root,text="Sync",width=30,command=sync).grid(row=1,\
                                                      column=0,\
                                                      columnspan=2)

    root.mainloop()

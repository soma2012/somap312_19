# encoding: utf-8

import csv
import matplotlib.font_manager
from pygooglechart import PieChart3D
from pylab import *



#tight_layout(pad=1.2, h_pad=1.2, w_pad=1.2)

rc('font', family='serif')
rc('font', serif='NanumGothic')
rc('font', size=12)
#title

"""
labels = [u'메롱', 'Hogs', 'Dogs', 'Logs']
fracs = [15,30,45, 10]


t = pie(fracs, labels=labels, autopct='%1.1f%%')
title(u'한글사랑', bbox={'facecolor':'0.8', 'pad':5})

show()
exit(0)
"""

t = []
with open('table.csv', 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    i=0
    list=[]


    for row in reader:
        if(i==0):
            for cell in row:
                list.append({})
                #'asdf'.replace("?", "")
                t.append(cell.replace("?", ""))

        if(i!=0):
            j=0
            for cell in row:
                dic = list[j]
                if(dic.has_key(cell)):
                    dic[cell]+=1
                else:
                    dic[cell]=1
                j+=1
        i+=1


"""
def custom_pct(pct):
    total=sum(values)
    val=int(pct*total/100.0)
    return '{p:.2f}%  ({v:d})'.format(p=pct,v=val)
"""

i=0
for x in list:
    labels=[]
    data=[]
    for y in x:
        if(x[y]>5 and y.strip()!=""):
            labels.append(y.decode('utf-8'))
            data.append(x[y])
        #print y + " " + str(x[y]);
        # Create a chart object of 250x100 pixels

#, autopct='%1.1f%%'
    #print data
    #print "XXXXXX"
    #print labels
    figure(1, figsize=(18,5))
    subplots_adjust(left=0.4, right=0.6)
    #figure(1, figsize=(6,6))
    #subplots_adjust(wspace=200)

    pie(data, labels=labels, autopct='%1.1f%%')
    title(t[i].decode('utf-8'), bbox={'facecolor':'0.8', 'pad':5})

    """
    #chart = PieChart3D(1000, 100,title=title[i])

    # Add some data
    chart.add_data(data)

    # Assign the labels to the pie data
    chart.set_pie_labels(labels)


    # Download the chart
    chart.download(title[i] + '.png')
    """

    savefig(t[i] + '.png')
    close()
    i+=1;

fp = open('report.html', 'w+')
fp.write('<html>')
fp.write('<head>')
fp.write('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />')
fp.write('</head>')
fp.write('<body>')
for x in t:
    fp.write('<p>')
    fp.write('<h1>'+x+'</h1>')
    fp.write('<img src="'+x+'.png" />')
    fp.write('</p>')

fp.write('</body>')
fp.write('</html>')
#!/usr/bin/env python

from twisted.web import server,resource
from twisted.internet import reactor
import twisted
import time
import mimetypes
import os
from cStringIO import StringIO


class Root(resource.Resource):
  def __init__(self):
    #fd = open("google.bmp" , "rb")
    fd = open("google.bmp" , "rb")
    self.bmp = fd.read()
    resource.Resource.__init__(self)
    fd.close()
  def getChild(self,name,request):
    self.filename = name
    #print name
    if name == "b": 
      print "name:b"
      request.setHeader("Cache-Control", "max-age=100")
    return self
  def render_GET(self,request):
    content_type = "text/html"
    #request.setHeader("Cache-Control", "max-age=1000")
    request.setHeader("Cache-Control", "private")
    request.setHeader("Cache-Control", "no-cache")
    data = StringIO()
    print "in request 1"
    print "file:%s"%(self.filename)
    if self.filename != "":
      filename_len = len(self.filename)
      #print filename_len
      if filename_len > 4:
        #print filename_len
        filename_ext = self.filename[filename_len-4:filename_len]
        if filename_ext == ".bmp":
          request.setHeader("Content-Type", "image/bmp")
          #print filename_ext
          data.write(self.bmp)
        else:
          if filename_ext == ".htm":
            #data.write("is htm")
            filename_pre = self.filename[0:filename_len-4]
            html = self.gen_img_request(filename_pre) 
            data.write(html)
          else:
            if filename_len > 5:
              filename_ext = self.filename[filename_len-5:filename_len]
              if filename_ext == ".html":
                filename_pre = self.filename[0:filename_len-5]
                #print filename_pre
                html = self.gen_img_request(filename_pre) 
                data.write(html)

        #if filename_ext == ".html":
      else:
        request.setHeader("Content-Type", content_type)
        data.write("test abc")
    else:
      request.setHeader("Content-Type", content_type)
      data.write("test abc")

    #print request
    print "in request 2"
    return data.getvalue()
  
  def gen_img_request(self, filename_pre):
    data = ""
    try:
      value = int(filename_pre)
      cnt = value 
      while cnt > 0:
        #data += """<img src= %d.bmp height=10 weight=10 />"""%(cnt)
        #data += """<img src= %d.bmp height=0 weight=0 />"""%(cnt)
        data += """<img src= %d.bmp />"""%(cnt)
        data += """<h1> %d </h1>"""%(cnt)
        cnt -= 5
    except:
      data = "this is a test page"
    return data


  def render_POST(self,request):
    return self.render_GET(request)


root = Root()

site = server.Site(root)
reactor.listenTCP(80, site)
reactor.run()

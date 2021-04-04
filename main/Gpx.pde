class Gpx
{
  
   PShape track, posts, thumbtacks;
   Map3D map;
   int selectionPoint;
   JSONArray features; 
    
   public Gpx(Map3D myMap)
   {
             this.map = myMap;
             
             //On initialise les trois PShape
             this.track = createShape();
             this.track.beginShape();
             this.track.noFill();
             
             this.posts = createShape();
             this.posts.beginShape(LINES);
             this.thumbtacks = createShape();
             this.thumbtacks.beginShape(POINTS);
             
             this.track.strokeWeight(2);
             this.track.stroke(144,238,144);
             this.posts.strokeWeight(1.5);
             this.posts.stroke(150,150,150);
             this.thumbtacks.stroke(0xFFFF3F3F);
             this.thumbtacks.strokeWeight(8);
            
             int heightPost = 100;
     
     
            String fileName = "trail.geojson";
            
            // Check ressources
            File ressource = dataFile(fileName);
            
            if (!ressource.exists() || ressource.isDirectory()) 
            {
             println("ERROR: GeoJSON file " + fileName + " not found.");
             return;
            }
            
            // Load geojson and check features collection
            JSONObject geojson = loadJSONObject(fileName);
            
            if (!geojson.hasKey("type")) 
            {
             println("WARNING: Invalid GeoJSON file.");
             return;
            } 
            else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) 
            {
             println("WARNING: GeoJSON file doesn't contain features collection.");
             return;
            }
            
            // Parse features
            JSONArray features = geojson.getJSONArray("features");
            if (features == null) 
            {
             println("WARNING: GeoJSON file doesn't contain any feature.");
             return;
            }
            
           
            
            
            
            
            
            for (int f=0; f<features.size(); f++) 
            {
              
             JSONObject feature = features.getJSONObject(f);
             if (!feature.hasKey("geometry"))
               break;
             JSONObject geometry = feature.getJSONObject("geometry");
             
             switch (geometry.getString("type", "undefined")) {
               
             case "LineString":
             // GPX Track
               JSONArray coordinates = geometry.getJSONArray("coordinates");
               if (coordinates != null)
                 for (int p=0; p < coordinates.size(); p++) 
                 {
                   JSONArray point = coordinates.getJSONArray(p);
                   Map3D.GeoPoint geopoint = this.map.new GeoPoint(point.getFloat(0),point.getFloat(1));
                   Map3D.ObjectPoint objPoint = this.map.new ObjectPoint(geopoint);
                   this.track.vertex(objPoint.x,objPoint.y,objPoint.z);
                   
                   
                   //println("Track ", p, point.getDouble(0), point.getDouble(1));
                 }
             break;
             
             
             case "Point":
             
               // GPX WayPoint
               if (geometry.hasKey("coordinates")) 
               {
                 JSONArray point = geometry.getJSONArray("coordinates");
                 String description = "Pas d'information.";
                 if (feature.hasKey("properties")) 
                 {
                   description = feature.getJSONObject("properties").getString("desc", description);
                 }
                 Map3D.GeoPoint geopoint = this.map.new GeoPoint(point.getFloat(0),point.getFloat(1));
                 Map3D.ObjectPoint objPoint = this.map.new ObjectPoint(geopoint);
                 this.posts.vertex(objPoint.x,objPoint.y,objPoint.z);
                 this.posts.vertex(objPoint.x,objPoint.y,objPoint.z+heightPost);
                 this.thumbtacks.vertex(objPoint.x,objPoint.y,objPoint.z+heightPost);
                 
                 
                 //println("WayPoint", point.getDouble(0), point.getDouble(1), description);
               }
             break;
             
            default:
             println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
             break;
             }
             
         }
       
       this.track.endShape();
       this.thumbtacks.endShape();
       this.posts.endShape();
 
 
     }
     
     
     
     void update()
     {
        shape(this.track);
        shape(this.thumbtacks);
        shape(this.posts);
        
     }
     
     
     void toggle()
     {
        this.track.setVisible(!this.track.isVisible());
        this.thumbtacks.setVisible(!this.thumbtacks.isVisible());
        this.posts.setVisible(!this.posts.isVisible());
       
     }
     
     
     void click(int mouseX, int mouseY)
     {
       
       float distanceMinimale = dist(0,0,(int)this.map.width,(int)this.map.height);
     
       for (int v=0; v < this.thumbtacks.getVertexCount(); v++)
       {
          PVector point = this.thumbtacks.getVertex(v);
          
          float distancePointSouris = dist(screenX(point.x,point.y,point.z), screenY(point.x,point.y,point.z), mouseX, mouseY );
          
          if(distancePointSouris < distanceMinimale)
          {
             distanceMinimale = distancePointSouris;
             this.selectionPoint = v;
            
          }
          
          
       }
       
       for(int foo = 0; foo <  this.thumbtacks.getVertexCount(); foo++)
       {
           if(foo == this.selectionPoint)
           {
              this.thumbtacks.setStroke(foo,0xFF3FFF7F);
              description(camera, foo);
           }
           else
           {
              this.thumbtacks.setStroke(foo,0xFFFF3F3F); 
           }
           
       }
       
       
     
     }
     
     void description(Camera camera, int vector)
     {
        String description = "";
        description = this.features.getJSONObject(vector).getJSONObject("properties").getString("desc",description);
        pushMatrix();
        lights();
        fill(0xFFFFFFFF);
        PVector hit = this.thumbtacks.getVertex(vector);
        translate(hit.x, hit.y, hit.z + 10.0f);
        rotateZ(-camera.longitude-HALF_PI);
        rotateX(-camera.colatitude);
        g.hint(PConstants.DISABLE_DEPTH_TEST);
        textMode(SHAPE);
        textSize(48);
        textAlign(LEFT, CENTER);
        text(description, 0, 0);
        g.hint(PConstants.ENABLE_DEPTH_TEST);
        popMatrix();
       
     } 
       
       
       
       
       
       
       
}
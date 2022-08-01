

/* [Box dimensions] */
  Length        = 180;       
  Width         = 385;                     
  TopHeight        = 10;  
  BottomHeight     = 21;  
  SlopeHeight      = 20;
  Thick         = 3;//[2:5]  


  
/* [Box options] */
  PCBFeet       = 1;// [0:No, 1:Yes]
  Vent          = 1;// [0:No, 1:Yes]
  Vent_width    = 1.5;   



  Filet         = 9;//[0.1:12] 
  Resolution    = 50;//[1:100] 
  m             = 0.9;
  
/* [PCB_Feet--the_board_will_not_be_exported) ] */
PCBPosX         = 0;
PCBPosY         = 0;
PCBLength       = 142;
PCBWidth        = 360;
FootHeight      = 5;
FootDia         = 8;
FootHole        = 4.4;  
  

/* [STL element to export] */
//Top shell
  TShell        = 1;// [0:No, 1:Yes]
//Bottom shell
  BShell        = 0;// [0:No, 1:Yes]
// logo plate  
  RLogo         = 0;// Logo


  
/* [Hidden] */
Couleur1        = "Orange";       
Couleur2        = "OrangeRed";    
Dec_Thick       = Vent ? Thick*2 : Thick; 
Dec_size        = Vent ? Thick*2 : 0.8;

PCBL=PCBLength;
PCBW=PCBWidth;



   
module SlopeRoundBox($a=Length, $b=Width, $c=TopHeight+BottomHeight){
                    $fn=Resolution;     
                         
                        translate([Filet,-Filet/2,Filet])
                        {  
                    minkowski ()
                    {  
              
                    translate([0,($b/2)+1,TopHeight])
                       rotate(a=[0,-90,90])
                          linear_extrude(height =(($b/2)-Filet/2)+1, center = false, convexity = 0, twist = 0)
                              polygon(points=[[0,0],[(SlopeHeight+TopHeight)*-1,0],[(SlopeHeight+TopHeight)*-1,-30],  [TopHeight*-1,($a-Filet*2)*-1],[0,($a-Filet*2)*-1]], paths=[[3,2,1,0]]);                      
                        
                     rotate([270,0,0]){    
                        cylinder(r=Filet,h=Width/2+1, center = false);
                            } 
                        }
                    }
                }// End of SlopeRoundBox Module                


module RoundBox($a=Length, $b=Width, $c=TopHeight+BottomHeight){
                    $fn=Resolution;            
                    translate([0,Filet,Filet]){  
                    minkowski (){                                              
                        cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
                        rotate([0,90,0]){   
                           translate([0,0,Filet]){  
                        cylinder(r=Filet,h=Length/2-(2*Filet), center = false);}
                            } 
                        rotate([270,0,0]){    
                        cylinder(r=Filet,h=.1, center = false);
                            } 
                        }
                    }
                }// End of RoundBox Module

      


module TopShell(){
    Thick = Thick*2;  
    difference(){    
        difference(){
            union(){    
                     difference() {
                      
                        difference(){
                            union() {
                                        KeyboardCutoutReinforcement();

                            difference(){
                                SlopeRoundBox();
                                translate([Thick/2,Thick/2,Thick/2]){     
                                        SlopeRoundBox($a=Length-Thick*2, $b=Width-Thick*2, $c=TopHeight+BottomHeight-Thick);
                                        }
                                        }
                                    }
                               translate([-Thick,-Thick,TopHeight]){
                                   cube ([Length+100, Width+100, TopHeight+BottomHeight], center=false);
                                            }                                            
                                      }
                                }                                          

                difference(){
                    union(){
                        translate([3*Thick +5,Thick,TopHeight]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }   
                            }
                            
                       translate([Length-((3*Thick)+5),Thick,TopHeight]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }   
                            }

                    translate([3*Thick +5,Width-Thick/2-2.4,TopHeight]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }   
                            }
                            
                       translate([Length-((3*Thick)+5),Width-Thick/2-2.4,TopHeight]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }   
                            }


                        }
                            
                    } 
                    
                    
            }

       }


///Put Difference Keyboard Cutout Here

            union(){ //sides holes
                $fn=50;
                translate([3*Thick+5,20,TopHeight+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),20,TopHeight+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([3*Thick+5,Width+5,TopHeight+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),Width+5,TopHeight+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
            }//fin de sides holes

         // IEC Opening    
            translate([-1,(Thick)+281,Thick-3]){
              cube([21,21,BottomHeight-7]);
            }   

         // Power Switch Opening    
            translate([-1,(Thick)+31,Thick-13]){
              cube([13,20,13]);
            }   


         // Reset Switch Opening    
            translate([-1,(Thick)+65,Thick-7]){
             rotate([0,90,0])
                    cylinder(d=7,20);
            }   


        // Power Jack Opening    
            translate([-1,(Thick)+95,Thick-7]){
             rotate([0,90,0])
                    cylinder(d=11,20);
            }   

        KeyboardCutout();

        }//fin de difference holes
        KeyboardFeet();
        

        
        

}// fin coque 





module BottomShell(){
    Thick = Thick*2;  
    translate([0,2,0]){
    
    difference(){    
        difference(){
            //Main Box
            union(){    
                     difference() {
                      
                        difference(){
                            union() {
                            difference(){
                                RoundBox($a=Length, $b=Width-2, $c=TopHeight+BottomHeight);
                                translate([Thick/2,Thick/2,Thick/2]){     
                                        RoundBox($a=Length-Thick, $b=Width-Thick-2, $c=TopHeight+BottomHeight-Thick);
                                        }
                                        }

                                    }
                               translate([-Thick,-Thick,BottomHeight]){// Cube à soustraire
                                   cube ([Length+100, Width+100, TopHeight+BottomHeight], center=false);
                                            }                                            
                                      }
                                }                                          


              
            }

       
            // vent holes
            union(){           
            for(i=[0:Thick:Length/4]){
                    translate([10+i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,BottomHeight/2]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,BottomHeight/2]);
                    }
               
                  }
                }
                
        
            // Joystick Opening    
            translate([53,Width-Dec_size-2,Thick]){    
              cube([75,Dec_Thick+2,BottomHeight-5]);
            }
                

            // expansion Opening    
            translate([-1,(Thick)+270,Thick]){
              cube([12,70,BottomHeight-3]);
            }   

            // Serial Opening    
            translate([-1,(Thick)+124,Thick]){
              cube([12,25,BottomHeight-3]);
            } 

            // Video, Audio, IEC Opening    
            translate([-1,(Thick)+25,Thick]){
              cube([21,65,BottomHeight-3]);
            }   

    
            // Glamour Line
        
            translate([Length-1,0,BottomHeight-1.25]){
             cube([20,Width,20]);
                }               
            translate([0,0,BottomHeight-1.25]){
             cube([1,Width,20]);
                }
             translate([0,0,BottomHeight-1.25]){    
              cube([Length,1,5]);
            }  
             translate([0,Width-3,BottomHeight-1.25]){    
              cube([Length,20,5]);
            }  
           
                
            }//fin difference decoration


            union(){ //sides holes
                $fn=50;
                translate([3*Thick+5,20,BottomHeight-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),20,BottomHeight-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([3*Thick+5,Width+5,BottomHeight-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),Width+5,BottomHeight-4]){
                   rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
            }
        }
        }
}



module thinFoot(FootDia,FootHole,FootHeight){
    Filet=2;
    color("Orange")   
    translate([0,0,Filet-1.5])
    difference(){
    
    difference(){
            //translate ([0,0,-Thick]){
                cylinder(d=(FootDia),FootHeight-Thick, $fn=100);
                        //}
                    rotate_extrude($fn=100){
                            translate([(FootDia)/1.75,0,0]){
                                    minkowski(){
                                            square(10);
                                            circle(Filet, $fn=100);
                                        }
                                 }
                           }
                   }
            cylinder(d=FootHole/2,FootHeight+1, $fn=100);
               }          
}

module foot(FootDia,FootHole,FootHeight){
    Filet=2;
    color("Orange")   
    translate([0,0,Filet-1.5])
    difference(){
    
    difference(){
            //translate ([0,0,-Thick]){
                cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);
                        //}
                    rotate_extrude($fn=100){
                            translate([(FootDia+Filet*2)/2,Filet,0]){
                                    minkowski(){
                                            square(10);
                                            circle(Filet, $fn=100);
                                        }
                                 }
                           }
                   }
            cylinder(d=FootHole,FootHeight+1, $fn=100);
               }          
}

module KeyboardCutout()
{
      color("OrangeRed"){
        translate([70,Width-20,-16])
          {
           rotate(a=[8,0,270])
           { 
               linear_extrude(height =15, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[-1,2],[289,2],[289,42],[296,42],[296,2],[335,2],[335,42],[289,42],[289,78],
                                                [296,78],[296,59],[317,59],[317,78],[336,78],[336,100],[277,100],
                                                [277,81],[264,81],[264,100],[47,100],[47,81],[27,81],[27,100],[-1,100]]
               , paths=[[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]]);        
               
               linear_extrude(height =12, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[35.5,-26],[135.5,-26],[135.5,-4],[35.5,-4]], paths=[[0,1,2,3]]);        
               
               linear_extrude(height =12, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[-1,-26],[20,-26],[20,-4],[-1,-4]], paths=[[0,1,2,3]]);        
               
           }
                            

               //LED OPENING
                 rotate(a=[8,0,270])
                            linear_extrude(height =12, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[7,-50],[17.1,-50],[17.1,-52.1],[7,-52.1]], paths=[[0,1,2,3]]);  
          }              
        }
    }

module KeyboardCutoutReinforcement()
{
    
      color("OrangeRed"){
        translate([70,Width-20,-14])
          {
                       rotate(a=[8,0,270])
           { 
                          linear_extrude(height =5, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[-3,0],[291,0],[291,44],[294,44],[294,0],[337,0],[337,44],[291,44],[291,76],[294,76],[294,57],[319,57],[319,76],[338,76],[338,102],[275,102],[275,83],[266,83],[266,102],[-3,102]], paths=[[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]]); 
               
                          linear_extrude(height =5, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[33.5,-28],[137.5,-28],[137.5,-2],[33.5,-2]], paths=[[0,1,2,3]]);      
                          
                          linear_extrude(height =5, center = false, convexity = 0, twist = 0)              
                                polygon(points=[[-3,-28],[22,-28],[22,-2],[-3,-2]], paths=[[0,1,2,3]]);        
           }
              
               
               
                            }              
        }
    }


module KeyboardFeet()
{
     color("OrangeRed"){         
        translate([70,Width-20,-15])
          {
                       rotate(a=[8,0,270])
           { 
               // top row
               translate([3*Thick+21,Thick-22.428,Thick/2]){foot(FootDia,FootHole,FootHeight+6);}
               translate([3*Thick+156.5,Thick-22.428,Thick/2]){foot(FootDia,FootHole,FootHeight+6);}
               
               translate([3*Thick+284,Thick+8,Thick/2]){thinFoot(FootDia,FootHole,FootHeight+7  );}
               
               translate([3*Thick+312,Thick+46.4,Thick/2]){foot(FootDia,FootHole,FootHeight+7  );}
               
               //bottom row
               translate([3*Thick+261.25,Thick+89.608,Thick/2]){foot(FootDia,FootHole,FootHeight+9);}
               translate([3*Thick+21,Thick+89.608,Thick/2]){thinFoot(FootDia,FootHole,FootHeight+9);}
               
               
               
               }
                            }              
        }
    }

module BottomFeet(){     
//////////////////// - PCB only visible in the preview mode - /////////////////////    
    translate([3*Thick-3,Thick+9,FootHeight+(Thick/2)]){
    
    %square ([PCBL,PCBW]);
       translate([PCBL/2,PCBW/2,0.5]){ 
        color("Olive")
        %text("PCB", halign="center", valign="center", font="Arial black");
       }
    } 




//top 
    translate([(3*Thick)-6.125+FootDia,(Thick)+PCBW-7.625+FootDia,Thick/2-8.2]){
        foot(FootDia,FootHole,FootHeight+8.4);
        }        

    translate([(3*Thick)-6.125+FootDia,(Thick)+PCBW-354.275+FootDia,Thick/2-8.2]){
        foot(FootDia,FootHole,FootHeight+8.4);
        }        


// middle
    translate([(3*Thick)+62.125-4.875+FootDia,(Thick)+PCBW-168.775+FootDia,Thick/2-8.2]){
        foot(FootDia,FootHole,FootHeight+8.4);
        }     


//bottom
    translate([(3*Thick)+130.625-5.875+FootDia,(Thick)+PCBW-7.625+FootDia,Thick/2-8.2]){
        foot(FootDia,FootHole,FootHeight+8.4);
        }        

    translate([(3*Thick)+130.625-5.875+FootDia,(Thick)+PCBW-354.275+FootDia,Thick/2-8.2]){
        foot(FootDia,FootHole,FootHeight+8.4);
        }        

}

module Logo()
{
    
    
union() {
scale([.65,.65, .65])
rotate([0,0,90])
    linear_extrude(height =4, center = false, convexity = 0, twist = 0)
               import(file = "n:/Projects/WE816/Support/logo.svg", center = true);    
    translate([-7,-25,0])
     cube([14,50,1.5]);
}
    
}






///////////////////////////////////// - Main - ///////////////////////////////////////



if(BShell==1)
{
    color(Couleur1){ 
        BottomShell();
    }
    if (PCBFeet==1)
    // Feet
    translate([PCBPosX,PCBPosY,0]){ 
    BottomFeet();
    }
}


if(TShell==1)
{
    color( Couleur1,1){
        translate([0,Width,TopHeight+BottomHeight+0.2]){
            rotate([0,180,180]){
                TopShell();
            }
        }
    }
 
}

if(RLogo==1)
{
    color( Couleur2,1){
        translate([-30,-30,0]){
            Logo();
        }
    }
} 


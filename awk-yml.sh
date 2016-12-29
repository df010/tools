#!/bin/bash
set -e
set -x
awk -v NAME="A"  '

function alength(arr,    n){
   n=0;
   for (i in arr) n++;
   return n;
}

function printA(arr,    n){
   n=0;
   for (i in arr) print i" = "arr[i];
}
function onEleStart(){
  push();
}

function onArrayStart(){
  FLAG[POSITION]=FLAG[POSITION-1];
  STACK[POSITION]="";
  BUFFER_DATA="";
  OPTION_MATCH=0;
}

function onEmpStart(){
  FLAG[POSITION]=FLAG[POSITION-1];
  STACK[POSITION]="";
}

function onEleEnd(    size){
  size=alength(STACK); 
  if(size == 0){
     return; 
  }
  while(size >0 && size > POSITION ){

    pop();
    size=alength(STACK);
  }
}

function pop(    size){
   size=alength(STACK);
   data=STACK[size-1];
   if(size >= 2 &&  FLAG[size -1] == 2 && FLAG[size-2] == 2 ){
       if( OPTION_MATCH ){
         print BUFFER_DATA;
       }
       BUFFER_DATA="";
   }

   delete STACK[size-1] ;
   delete FLAG[size-1] ;
}

function matchStatus(){
  if(match($0, "^releases:") ){
      return 3;
  }
  if(match($0, "^job_types:")){
      return 2;
  }  
  if(match($0, "^[-| ] name: (diego_cell|router) *$")){
      OPTION_MATCH=1;
  }
  return 0;
}

function wrapData(){
  return gensub(/( +[^ :]+: \(\( *) (\.)(.+\)\))/, "\\1$runtime\\2\\3", "g")
}

function push(    status){

  STACK[POSITION]=$0;
  status=matchStatus();
  if( status > 0){
      FLAG[POSITION]=status;
  }else if( POSITION > 0 ) {
    if(FLAG[POSITION -1] ==3 ||FLAG[POSITION -1] ==1 ){
      FLAG[POSITION]=FLAG[POSITION -1];
    }else if(FLAG[POSITION -1] ==2){
      FLAG[POSITION]=1;
    }else {
      FLAG[POSITION]=0;
    }
  }else {
    FLAG[POSITION]=0;
  }
  if( FLAG[POSITION] >=2 ){
      print $0;
  }else {
     if(FLAG[POSITION] ==1){
         BUFFER_DATA =  BUFFER_DATA wrapData()"\n"
    }
  }
}

function read(    currentPosition){
  currentPosition=0;
  if( match($0,"^---") || match($0,"^ *#")||match($0,"^ *$") ){
      return;
  }

  match($0,"^ *");

#TODO,  for time being ,just leave this as two layers
  if(RLENGTH > 0){
    currentPosition=2;
  }else if(substr($0,1,2) == "- "){
    currentPosition=1;
  }else {
    currentPosition=0;
  }

  if(currentPosition <= POSITION){
      POSITION=currentPosition;
      onEleEnd();
      if(POSITION == 1){
          onArrayStart();
          POSITION=2;
      }
      onEleStart();
  }else if(currentPosition > POSITION){
      POSITION=currentPosition;
      if(POSITION == 1){
          onArrayStart();
          POSITION=2;
      }else if(POSITION == 2){
          POSITION = 1;
          onEmpStart();
          POSITION =2;
      }
      onEleStart();
  }

}

BEGIN {
  print "---"
  print "name: "NAME;
  POSITION=-1;
} 
{
  read();
}
END {
  onEleEnd();
}
' metadata/cf.yml
#aa.yml 

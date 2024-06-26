#include <iostream>

class Object{
    virtual void init();
    virtual void update();
    virtual void render();
    virtual void release();
}

Object game;

void main(){
    game.init();

    while(true)
    {
        game.update();
        game.render();
    }

    game.release();
}

//
//  Slice.h
//  Monitor
//
//  Created by suihong on 16/8/31.
//  Copyright © 2016年 suihong. All rights reserved.
//

#ifndef Slice_h
#define Slice_h

#include <stdio.h>
typedef unsigned char uint8;

class Slice;

class SliceIMask
{
private:
    SliceIMask(){}
    SliceIMask(const SliceIMask& other) {}
    SliceIMask& operator=(const SliceIMask& other){ return *this;}
    
    friend class Slice;
    
private:
//    static constexpr unsigned int i_mask[33] =
//    {
//        0x00,
//        0x01,       0x03,       0x07,       0x0f,
//        0x1f,       0x3f,       0x7f,       0xff,
//        0x1ff,      0x3ff,      0x7ff,      0xfff,
//        0x1fff,     0x3fff,     0x7fff,     0xffff,
//        0x1ffff,    0x3ffff,    0x7ffff,    0xfffff,
//        0x1fffff,   0x3fffff,   0x7fffff,   0xffffff,
//        0x1ffffff,  0x3ffffff,  0x7ffffff,  0xfffffff,
//        0x1fffffff, 0x3fffffff, 0x7fffffff, 0xffffffff
//    };
    
};

class Slice
{
public:
    Slice(uint8 *const begin, uint8 *const end): m_ptr(begin), m_begin(begin), m_end(end), m_left(8){}

    
public:
    unsigned int getSliceHeader();
    void resetPtr();
    
    virtual ~Slice() {}
    
private:
    unsigned short getBit();
    
private:
    short m_left;
    const uint8 *m_ptr;
    const uint8 *m_begin;
    const uint8 *const m_end;
};

#endif /* Slice_h */

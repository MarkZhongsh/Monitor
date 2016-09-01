//
//  Slice.cpp
//  Monitor
//
//  Created by suihong on 16/8/31.
//  Copyright © 2016年 suihong. All rights reserved.
//

#include "Slice.h"

unsigned int Slice::getSliceHeader()
{
    static constexpr unsigned int i_mask[33] =
    {
        0x00,
        0x01,       0x03,       0x07,       0x0f,
        0x1f,       0x3f,       0x7f,       0xff,
        0x1ff,      0x3ff,      0x7ff,      0xfff,
        0x1fff,     0x3fff,     0x7fff,     0xffff,
        0x1ffff,    0x3ffff,    0x7ffff,    0xfffff,
        0x1fffff,   0x3fffff,   0x7fffff,   0xffffff,
        0x1ffffff,  0x3ffffff,  0x7ffffff,  0xfffffff,
        0x1fffffff, 0x3fffffff, 0x7fffffff, 0xffffffff
    };
    
    unsigned int result = 0;
    
    if(m_ptr > m_end)
        return -1;
    
    int i_ret;
    
    unsigned short bitMax = 32;
    int counter = 0;
    
    while(this->getBit() == 0 && this->m_ptr <= this->m_end && counter < bitMax)
    {
        counter++;
    }
    
    if(m_ptr > m_end)
        return -1;
    
    while(counter>=0)
    {
        if((i_ret = m_left - counter) >= 0)
        {
            result |= (*m_ptr >> i_ret) & i_mask[counter];
            m_left -= counter;
            
            if(m_left <= 0)
            {
                m_ptr++;
                m_left = 8;
            }
            
            break;
        }
        else
        {
            result |= (*m_ptr & i_mask[m_left]) << -i_ret;
            counter = -i_ret;
            
            m_ptr ++;
            m_left = 8;
            
            if(m_ptr > m_end)
                return -1;
        }
    }
    
    return (1 << counter)-1+result;
}

unsigned short Slice::getBit()
{
    uint8 result = 0;
    
    if(m_ptr > m_end)
        return result;
    
    m_left--;
    result |= (*m_ptr) >> m_left & 0x01;
    
    if(m_left <= 0)
    {
        m_ptr++;
        m_left = 8;
    }
    
    
    return result;
}

inline void Slice::resetPtr()
{
    m_ptr = m_begin;
    m_left = 8;
}


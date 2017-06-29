
#pragma once

//-------------------------------------------------
#include <cstdint>
#include <vector>

class JcImgData
{
public:
    JcImgData(const std::vector<uint32_t> & data, int w, int h);

    int w = 0;
    int h = 0;
    std::vector<uint32_t> data;
};




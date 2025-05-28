#ifndef ENUMERATE_DEVICES_H
#define ENUMERATE_DEVICES_H

#endif // ENUMERATE_DEVICES_H


#include <dshow.h>
#include <vector>
#include <string>
#include <iostream>

std::vector<std::string> enumerateDevices(const GUID& category);

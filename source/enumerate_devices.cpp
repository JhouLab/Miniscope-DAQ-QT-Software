
#include "enumerate_devices.h"

std::vector<std::string> enumerateDevices(const GUID& category) {
    std::vector<std::string> deviceNames;
    ICreateDevEnum* pDevEnum = nullptr;
    IEnumMoniker* pEnum = nullptr;
    IMoniker* pMoniker = nullptr;

    // Create the System Device Enumerator.
    HRESULT hr = CoCreateInstance(CLSID_SystemDeviceEnum, nullptr, CLSCTX_INPROC_SERVER, IID_ICreateDevEnum, (void**)&pDevEnum);
    if (FAILED(hr)) {
        std::cerr << "Error creating device enumerator: " << hr << std::endl;
        return deviceNames;
    }

    // Create an enumerator for the specified device category.
    hr = pDevEnum->CreateClassEnumerator(category, &pEnum, 0);
    if (hr == S_OK) {
        // Enumerate the devices.
        while (pEnum->Next(1, &pMoniker, nullptr) == S_OK) {
            IPropertyBag* pPropBag;
            hr = pMoniker->BindToStorage(nullptr, nullptr, IID_IPropertyBag, (void**)&pPropBag);
            if (SUCCEEDED(hr)) {
                VARIANT varName;
                VariantInit(&varName);
                hr = pPropBag->Read(L"FriendlyName", &varName, nullptr);
                if (SUCCEEDED(hr)) {
                    wchar_t* t = varName.bstrVal;
                    std::wstring ws(t);
                    std::string s(ws.begin(), ws.end());
                    deviceNames.push_back(s);
                    VariantClear(&varName);
                }
                pPropBag->Release();
            }
            pMoniker->Release();
        }
        pEnum->Release();
    }
    pDevEnum->Release();
    return deviceNames;
}

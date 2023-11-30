#ifndef MARKER_H
#define MARKER_H

#include <QObject>

struct Marker {
    Q_GADGET
    Q_PROPERTY(int position MEMBER position)
    Q_PROPERTY(int length MEMBER length)
    Q_PROPERTY(QString url MEMBER url)
public:
    // Constructors
    Marker() = default;
    Marker(int p)
    {
        position = p;
    };
    Marker(std::nullptr_t){};
    // Contents
    QString text;
    int position = 0;
    int length = 1;
    int key = 0;
    QString keyLetter;
    QString url;
    int requestType = 0;
};
Q_DECLARE_METATYPE(Marker);

#endif // MARKER_H

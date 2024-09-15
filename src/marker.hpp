#ifndef MARKER_H
#define MARKER_H

#include <QObject>

struct Marker {
    Q_GADGET
    Q_PROPERTY(int position MEMBER position)
    Q_PROPERTY(int length MEMBER length)
    Q_PROPERTY(QString url MEMBER url)
public:
    Marker() {
        position = 0;
    };
    explicit Marker(int p)
    {
        position = p;
    };
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

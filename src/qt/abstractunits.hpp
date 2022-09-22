#ifndef ABSTRACTUNITS_H
#define ABSTRACTUNITS_H

#include <QObject>

class AbstractUnits : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Cannot create")
public:
    enum Durations{
        VeryShortDuration = 50,
        ShortDuration = 100,
        LongDuration = 200,
        VeryLongDuration = 400,
        ToolTipDelay = 700,
        HumanMoment = 2000
    };
    Q_ENUM(Durations)

};

#endif // ABSTRACTUNITS_H

#include "qhttpserverfwd.h"

#include <QObject>

/// HelloWorld

class HelloWorld : public QObject
{
    Q_OBJECT

public:
    HelloWorld();

private Q_SLOTS:
    void handleRequest(QHttpRequest *req, QHttpResponse *resp);
};

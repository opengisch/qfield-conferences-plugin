import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import QtQuick3D
import QtQuick3D.Particles3D

import QtCore

import org.qfield
import org.qgis
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property var mapCanvas: iface.mapCanvas()
  property var positioning: iface.findItemByObjectName('positionSource')

  Component.onCompleted: {
    conferenceLocatorFilter.locatorBridge.registerQFieldLocatorFilter(conferenceLocatorFilter);
  }

  Component.onDestruction: {
    conferenceLocatorFilter.locatorBridge.deregisterQFieldLocatorFilter(conferenceLocatorFilter);
  }
  
  QFieldLocatorFilter {
    id: conferenceLocatorFilter

    name: "conference"
    displayName: "OPENGIS.ch Conference Utilities"
    prefix: "conf"
    locatorBridge: iface.findItemByObjectName('locatorBridge')

    source: Qt.resolvedUrl('conference.qml')

    Component.onCompleted: {
      if (conferenceLocatorFilter.description !== undefined) {
        conferenceLocatorFilter.description = "Returns a set of functionalities to enhance conference presence."
      }
    }

    property var fauxGnssPath: Qt.resolvedUrl('data/frankfurt.log');

    function triggerResult(result) {
      let type = result.userData.type
      if (type === "faux_gnss") {
        positioning.deviceId = 'file:' + UrlUtils.toLocalFile(conferenceLocatorFilter.fauxGnssPath) + ':250';
      } else if (type === "splash") {
        overlay3dDialog.open()
      }
    }
  }
  
  Dialog {
    id: overlay3dDialog
    parent: mainWindow.contentItem
    visible: false
    font: Theme.defaultFont
    padding: 0
    modal: false

    height: parent.height
    width: parent.width

    background: Rectangle {
      color: "#33000000"
    }

    Loader {
      anchors.fill: parent
      active: overlay3dDialog.opened
      sourceComponent: loading3d
    }
  }

  Component {
    id: loading3d

    Item {
      id: overlay
      visible: overlay3dDialog.visible
      enabled: overlay3dDialog.enabled
      anchors.fill: parent
      anchors.margins: -20

      View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
          clearColor: "#00000000"
          backgroundMode: SceneEnvironment.Color
          antialiasingMode: SceneEnvironment.NoAA
          antialiasingQuality: SceneEnvironment.High
        }

        PerspectiveCamera {
          id: camera
          property real cameraAnim: 0
          NumberAnimation {
            target: camera
            property: "cameraAnim"
            running: true
            loops: Animation.Infinite
            from: 0
            to: 2 * Math.PI
            duration: 40000
          }
          position: Qt.vector3d(Math.sin(cameraAnim * 3.0) * 800, 400, 1200 + Math.cos(cameraAnim) * 400)
          eulerRotation: Qt.vector3d(-20, Math.sin(cameraAnim * 3.0) * 30, 0)
        }

        PointLight {
          position: Qt.vector3d(0, 400, 0)
          brightness: 10
          ambientColor: Qt.rgba(0.3, 0.3, 0.3, 1.0)
        }

        ParticleSystem3D {
          id: psystem2
          startTime: 10000
          SpriteParticle3D {
            id: particle3
            sprite: Texture {
              source: "images/star3.png"
            }
            maxAmount: 1000
            color: "#40ffffff"
            colorVariation: Qt.vector4d(0.1, 0.1, 0.1, 0.2)
            fadeInEffect: SpriteParticle3D.FadeScale
            fadeInDuration: 2000
            fadeOutEffect: SpriteParticle3D.FadeScale
            fadeOutDuration: 2000
            alignMode: SpriteParticle3D.AlignTowardsTarget
            alignTargetPosition: camera.position
          }
          ParticleEmitter3D {
            particle: particle3
            shape: ParticleShape3D {
              fill: true
              type: ParticleShape3D.Sphere
            }
            position: Qt.vector3d(0, -500, -400)

            scale: Qt.vector3d(60, 60, 60)

            emitRate: 200
            lifeSpan: 10000
            particleRotationVariation: Qt.vector3d(0, 0, 180)
            particleRotationVelocityVariation: Qt.vector3d(0, 0, 50)
            particleScale: 5.0
            particleScaleVariation: 3.0
            velocity: VectorDirection3D {
              direction: Qt.vector3d(0, 0, 0)
              directionVariation: Qt.vector3d(20, 20, 20)
            }
          }
        }

        ParticleSystem3D {
          id: psystem
          running: false
          SequentialAnimation on time {
            loops: Animation.Infinite
            PauseAnimation {
              duration: 1500
            }
            NumberAnimation {
              to: 5000
              duration: 5000
              easing.type: Easing.InOutQuad
            }
            PauseAnimation {
              duration: 1500
            }
            NumberAnimation {
              to: 0
              duration: 5000
              easing.type: Easing.InOutQuad
            }
          }

          SpriteParticle3D {
            id: particle1
            sprite: Texture {
              source: "images/star3.png"
            }
            maxAmount: 4096
            colorTable: Texture {
              source: "images/color_table5.png"
            }
            color: "#d0ffffff"
            colorVariation: Qt.vector4d(0.0, 0.0, 0.0, 0.4)
            particleScale: 15.0
            billboard: true
            fadeInEffect: SpriteParticle3D.FadeNone
            fadeOutEffect: SpriteParticle3D.FadeNone
          }

          SpriteParticle3D {
            id: particle2
            sprite: Texture {
              source: "images/dot.png"
            }
            maxAmount: 4096
            colorTable: Texture {
              source: "images/color_table4.png"
            }
            color: "#60ffffff"
            colorVariation: Qt.vector4d(0.0, 0.0, 0.0, 0.4)
            particleScale: 6.0
            billboard: true
            fadeInEffect: SpriteParticle3D.FadeNone
            fadeOutEffect: SpriteParticle3D.FadeNone
          }

          ParticleEmitter3D {
            particle: particle1
            scale: Qt.vector3d(5.0, 5.0, 5.0)
            shape: ParticleCustomShape3D {
              source: "data/opengis_in.cbor"
            }
            lifeSpan: 5001
            emitBursts: [
              EmitBurst3D {
                time: 0
                amount: 4096
              }
            ]
            depthBias: -200
            particleRotationVariation: Qt.vector3d(0, 0, 180)
            particleRotationVelocityVariation: Qt.vector3d(80, 80, 80)
            particleScaleVariation: 0.5
            particleEndScale: 4.0
            particleEndScaleVariation: 2.0
            velocity: VectorDirection3D {
              direction: Qt.vector3d(-150, 100, 0)
              directionVariation: Qt.vector3d(150, 100, 100)
            }
          }

          ParticleEmitter3D {
            particle: particle2
            scale: Qt.vector3d(5.0, 5.0, 5.0)
            shape: ParticleCustomShape3D {
              source: "data/opengis_out.cbor"
            }
            lifeSpan: 5001
            emitBursts: [
              EmitBurst3D {
                time: 0
                amount: 4096 * 4
              }
            ]
            particleScale: 2.0
            particleEndScale: 1.0
            particleScaleVariation: 1.5
            particleEndScaleVariation: 0.8
            velocity: VectorDirection3D {
              direction: Qt.vector3d(0, 200, 0)
              directionVariation: Qt.vector3d(50, 50, 50)
            }
          }

          Attractor3D {
            particles: [particle1]
            position: Qt.vector3d(-200, 0, 0)
            scale: Qt.vector3d(4.0, 4.0, 4.0)
            shape: ParticleCustomShape3D {
              source: "data/heart_4096.cbor"
              randomizeData: true
            }
            duration: 4000
            durationVariation: 1000
          }

          Attractor3D {
            particles: [particle2]
            position: Qt.vector3d(200, 0, 0)
            scale: Qt.vector3d(6.0, 6.0, 6.0)
            shape: ParticleCustomShape3D {
              source: "data/qfield_logo.cbor"
            }
            duration: 4000
            durationVariation: 1000
          }
        }

        Item {
          id: messageItem
          width: parent.width
          height: 80
          anchors.top: parent.top
          anchors.topMargin: 20

          property var messages: ["QField, the mobile companion for QGIS", "Connect high precision RTK GNSS devices", "Collaborate in the field using QFieldCloud", "Extendable with plugins"]
          property int currentIndex: 0

          MultiEffect {
            id: effect
            source: textRow
            anchors.fill: textRow
            shadowEnabled: true
            shadowColor: Qt.rgba(0.0, 0.0, 0.0, 0.6)
            shadowHorizontalOffset: 2
            shadowVerticalOffset: 2
            shadowBlur: 1
            blurEnabled: true
            blurMax: 10
            blur: 5
          }

          Row {
            id: textRow
            spacing: 0
            width: parent.width
            anchors.centerIn: parent

            Text {
              id: textItem
              width: parent.width
              text: messageItem.messages[messageItem.currentIndex]
              font.pixelSize: 30
              font.bold: true
              color: "white"
              opacity: 0
              horizontalAlignment: Text.Center
              textFormat: Text.RichText
            }
          }

          SequentialAnimation {
            id: cycle
            loops: Animation.Infinite

            ParallelAnimation {
              NumberAnimation {
                target: textItem
                property: "opacity"
                from: 0
                to: 1
                duration: 500
                easing.type: Easing.InOutQuad
              }
              NumberAnimation {
                target: effect
                property: "blur"
                from: 5
                to: 0
                duration: 500
                easing.type: Easing.InOutQuad
              }
              NumberAnimation {
                target: textItem
                property: "x"
                from: -100
                to: 0
                duration: 2500
                easing.type: Easing.OutQuint
              }
            }

            PauseAnimation {
              duration: 2000
            }

            ParallelAnimation {
              NumberAnimation {
                target: textItem
                property: "x"
                from: 0
                to: 60
                duration: 2500
                easing.type: Easing.InQuint
              }
              SequentialAnimation {
                PauseAnimation {
                  duration: 2000
                }
                ParallelAnimation {
                  NumberAnimation {
                    target: textItem
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 500
                    easing.type: Easing.InOutQuad
                  }
                  NumberAnimation {
                    target: effect
                    property: "blur"
                    from: 0
                    to: 5
                    duration: 500
                    easing.type: Easing.InOutQuad
                  }
                }
              }

              PauseAnimation {
                duration: 1000
              }
            }
            ScriptAction {
              script: messageItem.currentIndex = (messageItem.currentIndex + 1) % messageItem.messages.length
            }
          }

          Component.onCompleted: cycle.start()
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          overlay3dDialog.close()
        }
      }
    }
  }
}

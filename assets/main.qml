/*
 * Copyright (c) 2013-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.4
import "pages"
import "sheets"

NavigationPane {
    
    id: navPane
    
    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            onTriggered: {
                var sp = settingsPage.createObject();
                navPane.push(sp);
                Application.menuEnabled = false;
            }
        }
        
        helpAction: HelpActionItem {
            title: qsTr("About") + Retranslate.onLocaleOrLanguageChanged
            onTriggered: {
                var hp = helpPage.createObject();
                navPane.push(hp);
                Application.menuEnabled = false;
            }
        }
        
        actions: [
            ActionItem {
                title: qsTr("Send feedback") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_feedback.png"
                
                onTriggered: {
                    _app.invokeFeedback();
                }
            },
            
            ActionItem {
                title: qsTr("Logout") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_sign_out.png"
                
                onTriggered: {
                    _app.logout();
                }
            }
        ]
    }
    
    onCreationCompleted: {
        var fp = folderPage.createObject();
        
        _app.currentAccountLoaded.connect(function(account) {
            fp.account = account;
            highCover.account = account;
        });
        _qdropbox.spaceUsageLoaded.connect(function(spaceUsage) {
            fp.spaceUsage = spaceUsage;
            highCover.spaceUsage = spaceUsage;
        });
        _app.sharedLinksLoaded.connect(function() {
            fp.path = "";
            navPane.push(fp);
        });
        
        _qdropbox.getCurrentAccount();
        _qdropbox.getSpaceUsage();
        _qdropbox.getSharedLinks();
        Application.thumbnail.connect(navPane.onThumbnail);
    }
    
    onPopTransitionEnded: {
        if (page.cleanUp !== undefined) {
            page.cleanUp();
        }
        page.destroy();
        Application.menuEnabled = true;
    }
    
    attachedObjects: [
        FilePickersSheet {
            id: pickersSheet
            
            onUploadStarted: {
                pickersSheet.close();
                navPane.push(uploadsPage.createObject());
            }
        },
        
        ComponentDefinition {
            id: helpPage
            HelpPage {}
        },
        
        ComponentDefinition {
            id: settingsPage
            SettingsPage {}
        },
        
        ComponentDefinition {
            id: propsPage
            PropertiesPage {
                onShowMembers: {
                    var mp = membersPage.createObject();
                    mp.name = name;
                    mp.path = path;
                    mp.sharedFolderId = sharedFolderId;
                    mp.isOwner = isOwner;
                    navPane.push(mp);
                }
            }
        },
        
        ComponentDefinition {
            id: downloadsPage
            DownloadsPage {}    
        },
        
        ComponentDefinition {
            id: uploadsPage
            UploadsPage {}    
        },
        
        ComponentDefinition {
            id: membersPage
            MembersPage {
                onShowAccount: {
                    var ap = accountPage.createObject();
                    ap.account = account;
                    navPane.push(ap);
                }
            }    
        },
        
        ShareFolderSheet {
            id: shareFolderSheet    
        },
        
        ComponentDefinition {
            id: accountPage
            AccountPage {}
        },
        
        ComponentDefinition {
            id: folderPage
            FolderPage {
                onListFolder: {
                    var fp = folderPage.createObject();
                    fp.path = path;
                    fp.name = name;
                    navPane.push(fp);
                }
                
                onShowProps: {
                    var pp = propsPage.createObject();
                    pp.tag = file[".tag"];
                    pp.name = file.name;
                    pp.pathLower = file.path_lower;
                    pp.pathDisplay = file.path_display;
                    pp.fileId = file.id;
                    pp.sharedFolderId = file.shared_folder_id || "";
                    pp.sharingInfo = file.sharing_info;
                    pp.size = file.size || 0;
                    pp.rev = file.rev || "";
                    pp.contentHash = file.content_hash || "";
                    pp.clientModified = file.client_modified || "";
                    pp.serverModified = file.server_modified || "";
                    pp.mediaInfo = file.media_info;
                    pp.membersCount = file.members_count || 0;
                    pp.isOwner = file.is_owner || false;
                    pp.url = file.url || "";
                    navPane.push(pp);
                }
                
                onShowDownloads: {
                    navPane.openDownloads();
                }
                
                onShowUploads: {
                    navPane.openUploads();
                }
                
                onUpload: {
                    pickersSheet.targetPath = path;
                    pickersSheet.open();
                }
                
                onShareFolder: {
                    shareFolderSheet.path = path;
                    shareFolderSheet.open();
                }
            }
        },
        
        SceneCover {
            id: cover
            content: HighCover {
                id: highCover
            }
        }
    ]
    
    function openDownloads() {
        var dp = downloadsPage.createObject();
        navPane.push(dp);
    }
    
    function openUploads() {
        var up = uploadsPage.createObject();
        navPane.push(up);
    }
    
    function onThumbnail() {
        highCover.update();
        Application.setCover(cover);
    }
}

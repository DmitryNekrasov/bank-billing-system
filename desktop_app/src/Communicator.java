import com.ericsson.otp.erlang.*;

import java.io.IOException;

public class Communicator {

    private String serverNodeName;
    private String selfNodeName;

    private boolean connected;

    private OtpConnection connection;

    public Communicator(String serverNodeName, String selfNodeName) {
        this.serverNodeName = serverNodeName;
        this.selfNodeName = selfNodeName;
        this.connected = false;
    }

    boolean connectToServer() {
        if (!connected) {
            OtpSelf self;
            OtpPeer server;
            try {
                self = new OtpSelf(selfNodeName);
                server = new OtpPeer(serverNodeName);
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
            self.setCookie(server.cookie());
            try {
                connection = self.connect(server);
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
            connected = true;
        }
        return true;
    }

}

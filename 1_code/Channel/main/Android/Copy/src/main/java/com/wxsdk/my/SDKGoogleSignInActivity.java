package com.wxsdk.my;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.changleyou.domino.R;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.SignInButton;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.unity3d.player.UnityPlayer;

/**
 * Activity to demonstrate basic retrieval of the Google user's ID, email address, and basic
 * profile.
 */
public class SDKGoogleSignInActivity extends AppCompatActivity {

    private static final String TAG = "SignInActivity";
    private static final int RC_SIGN_IN = 9001;

    private GoogleSignInClient mGoogleSignInClient;
    private TextView mStatusTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // [START configure_signin]
        // Configure sign-in to request the user's ID, email address, and basic
        // profile. ID and basic profile are included in DEFAULT_SIGN_IN.
        String clientId = getString(R.string.server_client_id);

        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                .requestIdToken(clientId)
                .build();
        // [END configure_signin]

        // [START build_client]
        // Build a GoogleSignInClient with the options specified by gso.
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso);
        // [END build_client]

    }

    @Override
    public void onStart() {
        super.onStart();

        Bundle bundle = this.getIntent().getExtras();
        //接收name值
        String name = bundle.getString("name");
        String json_data = bundle.getString("json_data");

        if (name.equals("SignIn"))
        {
            if (json_data.equals("force"))
            {
                signIn();
            }
            else
            {
                GoogleSignInAccount account = GoogleSignIn.getLastSignedInAccount(this);
                if (account != null && !account.isExpired()) {
                    updateUI(account, "");
                }
                else
                    signIn();
            }
        }
        else if (name.equals("SignOut"))
        {
            signOut();
        }
        else if (name.equals("RevokeAccess"))
        {
            revokeAccess();
        }
        else
        {
            Log.i("TAG", "Google Signin name=" + name);
        }
    }

    // [START onActivityResult]
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // Result returned from launching the Intent from GoogleSignInClient.getSignInIntent(...);
        if (requestCode == RC_SIGN_IN) {
            // The Task returned from this call is always completed, no need to attach
            // a listener.
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            handleSignInResult(task);
        }
    }
    // [END onActivityResult]

    // [START handleSignInResult]
    private void handleSignInResult(Task<GoogleSignInAccount> completedTask) {
        try {
            GoogleSignInAccount account = completedTask.getResult(ApiException.class);

            // Signed in successfully, show authenticated UI.
            updateUI(account, "");
        } catch (ApiException e) {
            // The ApiException status code indicates the detailed failure reason.
            // Please refer to the GoogleSignInStatusCodes class reference for more information.
            Log.w(TAG, "signInResult:failed code=" + e.getStatusCode());
            updateUI(null, e.toString());
        }
    }
    // [END handleSignInResult]

    // [START signIn]
    private void signIn() {
        Intent signInIntent = mGoogleSignInClient.getSignInIntent();
        startActivityForResult(signInIntent, RC_SIGN_IN);
    }
    // [END signIn]

    // [START signOut]
    private void signOut() {
        mGoogleSignInClient.signOut()
                .addOnCompleteListener(this, new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        String str = new JsonToString()
                                .AddJSONObject("result", 0)
                                .AddJSONObject("msg", "signout")
                                .GetString();
                        Log.i("Google", "Google SignOut str=" + str);
                        UnityPlayer.UnitySendMessage("SDK_callback", "OnGGSignOutResult", str);
                        finish();
                    }
                });
    }
    // [END signOut]

    // [START revokeAccess]
    private void revokeAccess() {
        mGoogleSignInClient.revokeAccess()
                .addOnCompleteListener(this, new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        String str = new JsonToString()
                                .AddJSONObject("result", 0)
                                .AddJSONObject("msg", "revokeAccess")
                                .GetString();
                        Log.i("Google", "Google RevokeAccess str=" + str);
                        UnityPlayer.UnitySendMessage("SDK_callback", "OnGGRevokeAccessResult", str);
                        finish();
                    }
                });
    }
    // [END revokeAccess]

    private void updateUI(@Nullable GoogleSignInAccount acct, String err) {
        if (acct != null)
        {
            String idToken = acct.getIdToken();
            String personName = acct.getDisplayName();
            String personGivenName = acct.getGivenName();
            String personFamilyName = acct.getFamilyName();
            String personEmail = acct.getEmail();
            String personId = acct.getId();
            Uri personPhoto = acct.getPhotoUrl();
            Log.i("Google", "Google SignIn URI=" + personPhoto.toString());
            Log.i("Google", "Google SignIn URI=" + personPhoto.getPath());
            Log.i("Google", "Google SignIn URI=" + personPhoto.getQuery());
            String str = new JsonToString()
                    .AddJSONObject("result", 0)
                    .AddJSONObject("msg", "signin")
                    .AddJSONObject("refresh_token", idToken)
                    .AddJSONObject("personName", personName)
                    .AddJSONObject("personGivenName", personGivenName)
                    .AddJSONObject("personFamilyName", personFamilyName)
                    .AddJSONObject("personEmail", personEmail)
                    .AddJSONObject("loginId", personId)
                    .AddJSONObject("iconUrl", personPhoto.toString())
                    .GetString();
            Log.i("Google", "Google SignIn str=" + str);
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGGSignInResult", str);
            acct = null;
        }
        else
        {
            String str = new JsonToString()
                    .AddJSONObject("result", 1)
                    .AddJSONObject("msg", "signin")
                    .AddJSONObject("err", err)
                    .GetString();
            Log.i("Google", "Google SignIn str=" + str);
            UnityPlayer.UnitySendMessage("SDK_callback", "OnGGSignInResult", str);
        }
        finish();
    }
 }

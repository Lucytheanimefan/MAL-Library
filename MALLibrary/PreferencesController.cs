﻿using System;

using Foundation;
using AppKit;
using Sparkle;
using Security;
using RestSharp;
using CoreGraphics;
using System.Threading;
namespace MALLibrary
{
	public partial class PreferencesController : NSWindowController
	{
		SUUpdater updater;
		public MyAnimeList malengine { get; set; }
		public void setUpdater(SUUpdater u)
		{
			// Point sparkle updater from app delegate so it can access the updater functions.
			updater = u;
		}
		public PreferencesController(IntPtr handle) : base(handle)
		{
			
		}
		public NSWindow getWindow()
		{
			return this.w;
		}
		[Export("initWithCoder:")]
		public PreferencesController(NSCoder coder) : base(coder)
		{
		}

		public PreferencesController() : base("Preferences")
		{
		}

		public override void AwakeFromNib()
		{
			base.AwakeFromNib();
			this.showpreferenceview();
			var rec = Keychain.retrieveaccount();
			if (rec != null)
			{
				logoutview.Hidden = false;
				loginview.Hidden = true;
				usernamelabel.StringValue = rec.Account;
			}
			appicon.Image = NSApplication.SharedApplication.ApplicationIconImage;
		}
		public void showpreferenceview()
		{
			prefview.AddSubview(new NSView());
			string selectedpref;
			// Retrieve last used preference pane
			if (NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedpref")) != null)
			{
				selectedpref = NSUserDefaults.StandardUserDefaults.ValueForKey(new NSString("selectedpref")).ToString();
			}
			else
			{
				selectedpref = "General";
			}
			toolbar.SelectedItemIdentifier = selectedpref;
			this.changepreferenceview();
			//w.SetContentSize(generalpref.IntrinsicContentSize);
		}
		partial void changePref(Foundation.NSObject sender)
		{
			this.changepreferenceview();
			NSUserDefaults.StandardUserDefaults.SetValueForKey(new NSString(toolbar.SelectedItemIdentifier), new NSString("selectedpref"));
		}
		private void changepreferenceview()
		{
			//this.showMessage(toolbar.SelectedItemIdentifier, "");
			CGSize vsize = new CGSize();
			CGPoint origin = new CGPoint();
			origin.X = 0;
			origin.Y = 0;
			switch (toolbar.SelectedItemIdentifier)
			{
				case "General":
					w.Title = "General";
					prefview.ReplaceSubviewWith(prefview.Subviews[0], new NSView());
					vsize.Height = 120;
					vsize.Width = 419;
					this.resizeWindowToView(generalpref.Frame.Size);
					prefview.ReplaceSubviewWith(prefview.Subviews[0], generalpref);
					generalpref.SetFrameOrigin(origin);
					break;
				case "Login":
					w.Title = "Login";
					prefview.ReplaceSubviewWith(prefview.Subviews[0], new NSView());
					vsize.Height = 312;
					vsize.Width = 419;
					this.resizeWindowToView(vsize);
					prefview.ReplaceSubviewWith(prefview.Subviews[0], loginpref);
					loginpref.SetFrameOrigin(origin);
					break;
				case "updates":
					w.Title = "Software Updates";
					prefview.ReplaceSubviewWith(prefview.Subviews[0], new NSView());
					vsize.Height = 185;
					vsize.Width = 419;
					this.resizeWindowToView(vsize);
					prefview.ReplaceSubviewWith(prefview.Subviews[0], updatepref);
					loginpref.SetFrameOrigin(origin);
					break;
			}
		}
		private void resizeWindowToView(CGSize size)
		{
			nfloat titlebarheight = w.Frame.Size.Height - w.ContentView.Frame.Size.Height;
			CGSize windowsize = new CGSize();
			windowsize.Width = size.Width;
			windowsize.Height = size.Height + titlebarheight;
			nfloat originX = w.Frame.Location.X + w.Frame.Size.Width;
			originX = originX - windowsize.Width;
			nfloat originY = w.Frame.Location.Y + w.Frame.Size.Height;
			originY = originY - windowsize.Height;
			CGRect WindowFrame = new CGRect(originX,originY, windowsize.Width, windowsize.Height);
			w.SetFrame(WindowFrame, true, true);
		}
		partial void gettingstarted(Foundation.NSObject sender)
		{
			this.OpenURL("https://github.com/Atelier-Shiori/MALLibrary/wiki/Getting-Started");
		}

		partial void login(Foundation.NSObject sender)
		{
			if (usernamefield.StringValue.Length == 0 || passwordfield.StringValue.Length == 0)
			{
				this.showMessage("Username or Password missing.", "Please enter your username and password and try again.");
				loginbut.KeyEquivalent = "\r";
			}
			else {
				string username = usernamefield.StringValue;
				string password = passwordfield.StringValue;
				Thread t = new Thread(() => performlogin(username, password));
				loginbut.Enabled = false;
				t.Start();
			}
		}

		public void performlogin(string username, string password)
		{
			IRestResponse response = malengine.login(username, password);
			var content = response.Content; // raw content as string
			InvokeOnMainThread(() =>
			{
				loginbut.Enabled = true;
				if (response.StatusCode.GetHashCode() == 200)
				{
					usernamelabel.StringValue = username;
					logoutview.Hidden = false;
					loginview.Hidden = true;
					usernamefield.StringValue = "";
					passwordfield.StringValue = "";
					this.showMessage("Login Successful", "Login is successful");
					bool success = Keychain.saveaccount(username, password);
				}
				else
				{
					logoutview.Hidden = true;
					loginview.Hidden = false;
					loginbut.KeyEquivalent = "\r";
					this.showMessage("MAL Library was unable to log you in since you don't have the correct username and/or password.", "Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again.");
				}
			});
		}
		partial void logout(Foundation.NSObject sender)
		{
			NSAlert a = new NSAlert();
			a.AddButton("Logout");
			a.AddButton("Cancel");
			a.MessageText = "Do you want to log out?";
			a.InformativeText = "Once you logged out, you need to log back in before you can use this application.";
			a.AlertStyle = NSAlertStyle.Informational;
			long choice = a.RunSheetModal(this.w);
			if (choice == (long)NSAlertButtonReturn.First)
			{
				var success = Keychain.removeaccount();
				logoutview.Hidden = true;
				loginview.Hidden = false;
				loginbut.KeyEquivalent = "\r";
			}

	
		}

		partial void reauthorize(Foundation.NSObject sender)
		{
			NSApplication.SharedApplication.BeginSheet(reauthorizepanel, w);
		}
		partial void performreauth(Foundation.NSObject sender)
		{
			if (reauthpassword.StringValue.Length == 0)
			{
				warningicon.Hidden = false;
				return;
			}
			string password = reauthpassword.StringValue;
			reauthorizepanel.Close();
			string username = usernamelabel.StringValue;
			var success = Keychain.removeaccount();
			if (success)
			{
				reauthpassword.StringValue = "";
				Thread t = new Thread(() => performlogin(username, password));
				t.Start();
			}
		}
		partial void cancelreauth(Foundation.NSObject sender)
		{

		}
		partial void registeraccount(Foundation.NSObject sender)
		{
			this.OpenURL("https://myanimelist.net/register.php");
		}

		private void showMessage(string message, string explaination)
		{
			NSAlert msgbox = new NSAlert();
			msgbox.MessageText = message;
			msgbox.InformativeText = explaination;
			msgbox.AlertStyle = NSAlertStyle.Warning;
			msgbox.RunSheetModal(this.w);

		}
		private void OpenURL(string URL)
		{
			NSUrl link = new NSUrl(URL);
			NSWorkspace.SharedWorkspace.OpenUrl(link);
		}
		partial void checkforupdates(Foundation.NSObject sender)
		{
			updater.CheckForUpdates(sender);
		}
	}
}
